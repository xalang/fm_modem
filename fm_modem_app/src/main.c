#include "xparameters.h"
#include "xaxidma.h"
#include "xil_cache.h"
#include "ff.h"
#include "xil_printf.h"

#define BUF_SIZE 256

static XAxiDma AxiDma;
static FATFS fatfs;
static FIL fil;

static int init_dma()
{

    XAxiDma_Config *CfgPtr = XAxiDma_LookupConfig(XPAR_XAXIDMA_0_BASEADDR);
    if (!CfgPtr) {
        xil_printf("DMA LookupConfig failed\r\n");
        return XST_FAILURE;
    }

    XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    XAxiDma_Reset(&AxiDma);
    while (!XAxiDma_ResetIsDone(&AxiDma));

    return XST_SUCCESS;
}

static int fill_buffer(u32 *buf, UINT *bytes)
{
    FRESULT res = f_read(&fil, buf, BUF_SIZE * sizeof(u32), bytes);
    if (res != FR_OK) return XST_FAILURE;

    if (*bytes > 0)
        Xil_DCacheFlushRange((UINTPTR)buf, *bytes);

    return XST_SUCCESS;
}

static int dma_send(u32 *buf, UINT bytes)
{
    return XAxiDma_SimpleTransfer(
        &AxiDma,
        (UINTPTR)buf,
        bytes,
        XAXIDMA_DMA_TO_DEVICE
    );
}

int main()
{
    FRESULT res;
    int status;

    xil_printf("Starting SD → DMA ping-pong stream...\r\n");

    // -----------------------------
    // 1. Mount SD card
    // -----------------------------
    res = f_mount(&fatfs, "0:/", 1);

    if (res != FR_OK) {
        xil_printf("SD mount failed\n");
        return XST_FAILURE;
    }

    // -----------------------------
    // 2. Open file
    // -----------------------------
    res = f_open(&fil, "audio.bin", FA_READ);
    if (res != FR_OK) {
        xil_printf("File open failed\n");
        return XST_FAILURE;
    }

    // -----------------------------
    // 3. Init DMA
    // -----------------------------

    status = init_dma();
    if (status != XST_SUCCESS) {
        xil_printf("DMA init failed\n");
        return XST_FAILURE;
    }

    // -----------------------------
    // 4. Streaming loop
    // -----------------------------
    
    u32 buffer[BUF_SIZE] __attribute__((aligned(64)));
    UINT bytes = 0;

    while (1)
    {
        // Read from SD
        if (fill_buffer(buffer, &bytes) != XST_SUCCESS) {
            xil_printf("SD read failed\n");
            break;
        }

        if (bytes == 0) {
            xil_printf("EOF reached\n");
            break;
        }

        // Flush cache before DMA
        Xil_DCacheFlushRange((UINTPTR)buffer, bytes);

        // Send via DMA
        status = dma_send(buffer, bytes);
        if (status != XST_SUCCESS) {
            xil_printf("DMA transfer failed\n");
            break;
        }

        // Wait for completion
        while (XAxiDma_Busy(&AxiDma, XAXIDMA_DMA_TO_DEVICE));
    }

    // -----------------------------
    // 6. Cleanup
    // -----------------------------
    f_close(&fil);

    xil_printf("Streaming complete.\n");
    return 0;
}

