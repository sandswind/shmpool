#include "cmn_base.h"
#include "cmn_log.h"
#include "cmn_shmm.h"
#include "sms_bucket.h"

int
main(int argc, char **argv)
{
    int code = 1;
    int ret = 0;
    int64_t key = 90999;
    int64_t base_size = 0;
    struct base        *addr = NULL;
    struct base_config *cfgs = NULL;
    struct base        root;
    char   test[256];


    if (log_open(LOG_DEBUG, "console") != CMN_OK) {
        printf("init log error\n");
        exit(code);
    }

    cfgs = cmn_alloc(sizeof(struct base_config) *2);
    cfgs[0].type = SMS_RECORD_TYPE_RING;
    cfgs[0].cap  = 64;
    cfgs[0].elem_size = sizeof(char) * 16;

    cfgs[1].type = SMS_RECORD_TYPE_ARRAY;
    cfgs[1].cap  = 128;
    cfgs[1].elem_size = sizeof(long) * 40;

    base_size = sms_calc_size(cfgs, 2);

    if (shmm_create(key, base_size, &addr) < 0) {
        printf("shm create error\n");
        exit(code);
    }

    printf("shm size %d\n", base_size);
    printf("shm addr %p\n", addr);

    ret = sms_init(addr, cfgs, 2, base_size);
    sms_info(addr);

    memset(test, 0x41, 16);
    test[16] = 0x00;

    ret = sms_push(addr, 1, &test, 16);
    printf("push16 ret %d\n", ret);

    memset(test, 0x00, 256);
    ret = sms_pop(addr, 1, &test);
    printf("pop16 ret %s\n", test);

    if (shmm_destroy(key, addr) != 0) {
        printf("shm remove error\n");
        exit(code);
    }

    log_close();

    exit(code);
}
