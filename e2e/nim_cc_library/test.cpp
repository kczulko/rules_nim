#include <lib.h>
#include <gtest/gtest.h>

namespace my {
    namespace project {
        namespace {

#ifdef __cplusplus
            extern "C" {
#endif
                void library_init();
                void library_deinit();
                int add5(int);
#ifdef __cplusplus
            }
#endif

            class SharedLibTest : public testing::Test {
                protected:
                void SetUp() override {
                    library_init();
                }

                void TearDown() override {
                    library_deinit();
                }
            };

            // Tests that Foo does Xyz.
            TEST_F(SharedLibTest, CallsImportedFunction) {
                EXPECT_EQ(add5(5), 10);
            }

        }  // namespace
    }  // namespace project
}  // namespace my

int main(int argc, char **argv) {
  testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
