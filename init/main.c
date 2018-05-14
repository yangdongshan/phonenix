#include <stm32f4xx_conf.h> 


void ms_delay(int ms)
{
    while (ms-- > 0) {
        volatile int x = 5971;
        while (x--) {
            __asm("nop");
        }
    }
}

int os_start()
{
    GPIO_InitTypeDef GPIO_InitStructure;

    //arch_init();

    //board_init();

    //os_init();

    //user_main();

    //thread_become_idle();


    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOG, ENABLE);

    GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_14;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
    GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL ;

    GPIO_Init(GPIOG, &GPIO_InitStructure);

    for ( ; ;)  {
        ms_delay(500);
        GPIO_SetBits(GPIOG, GPIO_Pin_13);
        GPIO_ResetBits(GPIOG, GPIO_Pin_14);
        ms_delay(500);
        GPIO_ResetBits(GPIOG, GPIO_Pin_13);
        GPIO_SetBits(GPIOG, GPIO_Pin_14);
    }

    return 0;
}
