import time

def time_process(process):
    t1 = time.time()
    output = process.communicate()
    t2 = time.time()

    execution_time = t2 - t1
    stdout = output[0]
    stderr = output[1]

    return execution_time, stdout, stderr
