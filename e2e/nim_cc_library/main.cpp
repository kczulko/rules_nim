#include <stdio.h>
#include <lib.h>



int main() {
    library_init();
    library_do_something(0);
    printf("add5(5) = %d\n", add5(5));
    library_deinit();
    return 0;
}
