/* -------------------------------------------------------------------------- *
 * Estimate the run time from the statistics on a log file.                   *
 *                                                                            *
 * Assumes access time is less than the changed time as the access time is    *
 * set when the log file is opened.                                           *
 * -------------------------------------------------------------------------- */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    struct stat statbuf;
    
    if (argc < 2)
    {
        fprintf(stderr, "No file name provided\n");
        exit(EXIT_FAILURE);
    }

    if (stat(argv[1], &statbuf) == -1)
    {
        fprintf(stderr, "stat of %s failed: %m\n", argv[1]);
        exit(EXIT_FAILURE);
    }
    
    long diff     = statbuf.st_mtim.tv_sec - statbuf.st_atim.tv_sec;
    int num_days  = diff / 86400;
    int remaining = diff - 86400 * num_days;
    int num_hours = remaining / 3600;
    remaining    -= 3600*num_hours;
    int num_mins  = remaining / 60;
    int num_secs  = remaining - 60*num_mins;
    
    printf( "%3dd %2dh %2dm %2ds\n", num_days, num_hours, num_mins, num_secs );
    
    exit(EXIT_SUCCESS);
}
