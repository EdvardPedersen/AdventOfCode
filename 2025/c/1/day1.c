#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int rotate(int *dial, char *line) {
    int direction = 1;
    int passed_null = 0;
    if(line[0] == 'L') direction = -1;
    unsigned int num = atoi((line + 1));
    for(int i = 0; i < num; i++) {
        *dial += direction;
        if(*dial < 0) *dial = 99;
        if(*dial > 99) *dial = 0;
        if(*dial == 0) passed_null += 1;
    }
    return passed_null;
}

int main() {
    // Open input file
    FILE *f = fopen("input", "r");
    if(!f) return 0;

    // Find file size
    fseek(f, 0, SEEK_END);
    unsigned long file_size = ftell(f);
    fseek(f, 0, SEEK_SET);

    // Allocate memory and read file contents
    char *buf = malloc(file_size);
    fread(buf, file_size, 1, f);
    
    int pointing_at = 50;
    int num_null_end = 0;
    int num_passed_null = 0;

    // Set up tokenization
    char *line = strtok(buf, "\n");
    do {
        num_passed_null += rotate(&pointing_at, line);
        if(pointing_at == 0) num_null_end += 1;
    } while(line = strtok(NULL, "\n"));
    printf("%d stopped at 0\n", num_null_end);
    printf("%d total\n", num_passed_null);

    return 0;
}
