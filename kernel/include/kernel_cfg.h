#ifndef __KERNEL_CFG_H
#define __KERNEL_CFG_H

// max thread name len
#define MAX_THREAD_NAME_LEN (32)

#define MAX_THREAD_CNT      (32)
// idle thread, statistic thread, main thread
#define MIN_THREAD_CNT      (3)

// max thread id
#define MAX_THREAD_ID (MAX_THREAD_CNT - 1)

// max thread priority
#define MAX_THREAD_PRIORITY (MAX_THREAD_CNT)

#endif // __KERNEL_CFG_H
