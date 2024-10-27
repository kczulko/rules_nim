#include <stdio.h>
#include <lib.h>

#ifdef __cplusplus
extern "C" {
dupadupa
#endif
void library_init(void);
void library_deinit();
int add5(int);
#ifdef __cplusplus
}
#endif

int main() {
    /* square(3); */
    library_init();
    library_do_something(0);
    printf("add5(5) = %d\n", add5(5));
    library_deinit();
    return 0;
}
