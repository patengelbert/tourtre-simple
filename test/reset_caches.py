import os


def reset_caches():
    # print("Re enable cache reset")
    os.system("sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches;'")