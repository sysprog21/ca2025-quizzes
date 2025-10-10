#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define VECTOR_MIN_SIZE 16

typedef struct {
    void **data;
    size_t size;      /* Allocated size */
    size_t count;     /* Number of elements */
    size_t free_slot; /* Index of a known hole */
} vector_t;

typedef void (*vector_delete_callback_t)(void *);
typedef void *(*vector_foreach_callback_t)(void *, void *);

/* Initialize vector */
void vector_init(vector_t *v)
{
    v->data = NULL;
    v->size = 0;
    v->count = 0;
    v->free_slot = 0;
}

/* Push element to vector, returns index */
int32_t vector_push(vector_t *v, void *ptr)
{
    if (!v->size) {
        v->size = VECTOR_MIN_SIZE;
        v->data = calloc(v->size, sizeof(void *));
    }

    /* Reuse free slot if available */
    if (v->free_slot && v->free_slot < v->count) {
        size_t idx = v->free_slot;
        v->data[idx] = ptr;
        v->free_slot = 0;
        return idx;
    }

    /* Resize if needed */
    if (v->count == v->size) {
        v->size *= 2;
        v->data = realloc(v->data, v->size * sizeof(void *));
        memset(v->data + v->count, 0, (v->size - v->count) * sizeof(void *));
    }

    v->data[v->count] = ptr;
    return v->count++;
}

/* Pop last element */
void *vector_pop(vector_t *v)
{
    if (!v->count)
        return NULL;
    void *last = v->data[--v->count];
    v->data[v->count] = NULL;
    return last;
}

/* Get element at index */
void *vector_get_at(vector_t *v, size_t index)
{
    return (index < v->count) ? v->data[index] : NULL;
}

/* Set element at index (replaces existing) */
void *vector_set_at(vector_t *v, size_t index, void *ptr)
{
    if (index >= v->count)
        return NULL;
    v->data[index] = ptr;
    return ptr;
}

/* Get last element */
void *vector_get_end(vector_t *v)
{
    return v->count ? v->data[v->count - 1] : NULL;
}

/* Delete at index (creates hole) */
void vector_delete_at(vector_t *v, size_t index)
{
    if (index < v->count) {
        v->data[index] = NULL;
        v->free_slot = index;
    }
}

/* Iterate over elements */
void *vector_for_each(vector_t *v, vector_foreach_callback_t cb, void *data)
{
    if (!cb)
        return NULL;

    for (size_t i = 0; i < v->count; i++) {
        if (!v->data[i])
            continue;
        void *ret = cb(v->data[i], data);
        if (ret)
            return ret;
    }
    return NULL;
}

/* Delete all elements */
void vector_delete_all(vector_t *v, vector_delete_callback_t dc)
{
    for (void *p; (p = vector_pop(v));) {
        if (dc)
            dc(p);
    }
}

/* Free vector memory */
void vector_free(vector_t *v)
{
    if (!v->data)
        return;

    free(v->data);
    v->data = NULL;
    v->size = 0;
    v->count = 0;
    v->free_slot = 0;
}

/* Get number of elements */
size_t vector_used(vector_t *v)
{
    return v->count;
}

/* Test suite */

void *test_for_each_callback(void *element, void *data)
{
    (*(int *) data)++;
    return NULL;
}

void test_delete_callback(void *element)
{
    /* Would free element in real use */
}

void test_vector_init()
{
    printf("Testing vector_init... ");
    vector_t v;
    vector_init(&v);
    assert(v.data == NULL);
    assert(v.size == 0);
    assert(v.count == 0);
    assert(v.free_slot == 0);
    printf("PASSED\n");
}

void test_vector_push_pop()
{
    printf("Testing vector_push and vector_pop... ");
    vector_t v;
    vector_init(&v);

    int data1 = 42, data2 = 84, data3 = 126;

    assert(vector_push(&v, &data1) == 0);
    assert(vector_used(&v) == 1);

    assert(vector_push(&v, &data2) == 1);
    assert(vector_used(&v) == 2);

    assert(vector_push(&v, &data3) == 2);
    assert(vector_used(&v) == 3);

    assert(vector_pop(&v) == &data3);
    assert(vector_used(&v) == 2);

    assert(vector_pop(&v) == &data2);
    assert(vector_used(&v) == 1);

    assert(vector_pop(&v) == &data1);
    assert(vector_used(&v) == 0);

    assert(vector_pop(&v) == NULL);

    vector_free(&v);
    printf("PASSED\n");
}

void test_vector_get_at()
{
    printf("Testing vector_get_at... ");
    vector_t v;
    vector_init(&v);

    int data1 = 10, data2 = 20, data3 = 30;

    vector_push(&v, &data1);
    vector_push(&v, &data2);
    vector_push(&v, &data3);

    assert(vector_get_at(&v, 0) == &data1);
    assert(*(int *) vector_get_at(&v, 0) == 10);

    assert(vector_get_at(&v, 1) == &data2);
    assert(*(int *) vector_get_at(&v, 1) == 20);

    assert(vector_get_at(&v, 2) == &data3);
    assert(*(int *) vector_get_at(&v, 2) == 30);

    assert(vector_get_at(&v, 3) == NULL);
    assert(vector_get_at(&v, 100) == NULL);

    vector_free(&v);
    printf("PASSED\n");
}

void test_vector_delete_at()
{
    printf("Testing vector_delete_at... ");
    vector_t v;
    vector_init(&v);

    int data1 = 100, data2 = 200, data3 = 300, data4 = 400;

    vector_push(&v, &data1);
    vector_push(&v, &data2);
    vector_push(&v, &data3);

    vector_delete_at(&v, 1);
    assert(v.free_slot == 1);
    assert(vector_get_at(&v, 1) == NULL);

    /* Push reuses free slot */
    assert(vector_push(&v, &data4) == 1);
    assert(v.free_slot == 0);
    assert(vector_get_at(&v, 1) == &data4);
    assert(*(int *) vector_get_at(&v, 1) == 400);

    vector_free(&v);
    printf("PASSED\n");
}

void test_vector_for_each()
{
    printf("Testing vector_for_each... ");
    vector_t v;
    vector_init(&v);

    int data1 = 1, data2 = 2, data3 = 3;

    vector_push(&v, &data1);
    vector_push(&v, &data2);
    vector_push(&v, &data3);

    int counter = 0;
    vector_for_each(&v, test_for_each_callback, &counter);
    assert(counter == 3);

    vector_free(&v);
    printf("PASSED\n");
}

void test_vector_delete_all()
{
    printf("Testing vector_delete_all... ");
    vector_t v;
    vector_init(&v);

    int data1 = 10, data2 = 20, data3 = 30;

    vector_push(&v, &data1);
    vector_push(&v, &data2);
    vector_push(&v, &data3);

    assert(vector_used(&v) == 3);

    vector_delete_all(&v, test_delete_callback);
    assert(vector_used(&v) == 0);
    assert(vector_pop(&v) == NULL);

    vector_free(&v);
    printf("PASSED\n");
}

void test_vector_resize()
{
    printf("Testing vector automatic resize... ");
    vector_t v;
    vector_init(&v);

    /* Push more than initial size */
    for (int i = 0; i < 100; i++)
        vector_push(&v, (void *) (intptr_t) i);

    assert(vector_used(&v) == 100);
    assert(v.size >= 100);

    /* Verify all elements */
    for (int i = 0; i < 100; i++)
        assert((intptr_t) vector_get_at(&v, i) == i);

    vector_free(&v);
    printf("PASSED\n");
}

void test_vector_get_end()
{
    printf("Testing vector_get_end... ");
    vector_t v;
    vector_init(&v);

    int data1 = 111, data2 = 222, data3 = 333;

    assert(vector_get_end(&v) == NULL);

    vector_push(&v, &data1);
    assert(vector_get_end(&v) == &data1);

    vector_push(&v, &data2);
    assert(vector_get_end(&v) == &data2);

    vector_push(&v, &data3);
    assert(vector_get_end(&v) == &data3);

    vector_free(&v);
    printf("PASSED\n");
}

void test_vector_set_at()
{
    printf("Testing vector_set_at... ");
    vector_t v;
    vector_init(&v);

    int data1 = 1, data2 = 2, data3 = 3, data4 = 999;

    vector_push(&v, &data1);
    vector_push(&v, &data2);
    vector_push(&v, &data3);

    size_t initial_size = vector_used(&v);
    assert(vector_set_at(&v, 1, &data4) == &data4);
    assert(vector_used(&v) == initial_size); /* Size unchanged */
    assert(vector_get_at(&v, 1) == &data4);

    assert(vector_set_at(&v, 10, &data4) == NULL); /* Out of bounds */

    vector_free(&v);
    printf("PASSED\n");
}

int main()
{
    printf("=== Running Vector Tests ===\n");

    test_vector_init();
    test_vector_push_pop();
    test_vector_get_at();
    test_vector_delete_at();
    test_vector_for_each();
    test_vector_delete_all();
    test_vector_resize();
    test_vector_get_end();
    test_vector_set_at();

    printf("\n=== All Tests Passed ===\n");

    return 0;
}
