#include <stdio.h>
#include <lib.h>

namespace external {
    extern "C" {
        void library_init();
        void library_deinit();
        int add5(int);
    }
}

int main() {
    external::library_init();
    printf("add5(5) = %d\n", external::add5(5));
    external::library_deinit();
    return 0;
}
