#include <stdio.h>

void B(char *s, int two, int three);


//void (*Z)(char *, int, int) = B;
typedef void (*some_func_ptr_t)(char *, int, int);
some_func_ptr_t Z = B;

void D(char *s, int two, int three)
{
    printf("D\n");
    int i;
    for(i = 0; i < 2; i++){
        printf("  D loop iteration %d\n", i);
    }
}

void C(char *s, int four, int five, int six)
{
    printf("Args to C are:\n");
    printf("  %s\n", s);
    printf("  %d\n", four);
    printf("  %d\n", five);
    printf("  %d\n", six);
    B("str arg to B (from C)", 22, 33);
}

void B(char *s, int two, int three)
{
    printf("B\n");
    int i;
    for(i = 0; i < 2; i++){
        printf("  B loop iteration %d\n", i);
    }
}

void A(char *s, int one, int two, int three, int four)
{
    printf("Args to A are:\n");
    printf("  %s\n", s);
    printf("  %d\n", one);
    int i;
    for(i = 0; i < 2; i++){
        //B("str arg to B", 2, 3);
        Z("some func ptr invocation", 4, 2);
    }
    C("str arg to C", 4, 5, 6);
}
void A3(char *s, int one, int two, int three, int four)
{
    printf("Args to A are:\n");
    printf("  %s\n", s);
    printf("  %d\n", one);
    int i;
    for(i = 0; i < 2; i++){
        B("str arg to B", 2, 3);
        //Z("some func ptr invocation", 4, 2);
    }
    C("str arg to C", 4, 5, 6);
}
void A5(char *s, int one, int two, int three, int four)
{
    printf("Args to A are:\n");
    printf("  %s\n", s);
    printf("  %d\n", one);
    int i;
    for(i = 0; i < 1; i++){
        //B("str arg to B", 2, 3);
        Z("some func ptr invocation", 4, 2);
    }
}



int test_0(void)
{
    printf("hello world\n");
    return 0;
}
int test_1(void)
{
    D("str arg to D", 22, 33);
    return 0;
}
int test_2(void)
{
    B("str arg to B", 22, 33);
    return 0;
}
int test_3(void)
{
    A3("str arg to A", 11, 101, 102, 105);
    return 0;
}
int test_4(void)
{
    Z("str arg to B (invoked via Z)", 22, 33);
    return 0;
}
int test_5(void)
{
    A5("str arg to A", 11, 101, 102, 105);
    return 0;
}
int test_9(void)
{
    A("str arg to A", 11, 101, 102, 105);
    return 0;
}




int main(void)
{
    //test_0();
    //test_1();
    //test_2();
    //test_3();
    //test_4();
    //test_5();
    test_9();
    return 0;
}
