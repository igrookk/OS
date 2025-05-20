#include "lab2.h"
#include <pthread.h>
#include <semaphore.h>
#include <unistd.h>
#include <string>
#include <iostream>

// Количество итераций
const int NUM_ITERATIONS = 3;

// Семафоры
sem_t sem_d, sem_e, sem_f, sem_g, sem_k;
sem_t sem_h_start, sem_i_done;
sem_t sem_m_from_d, sem_m_from_i;
sem_t sem_n;

// Мьютекс для вывода
pthread_mutex_t output_mutex = PTHREAD_MUTEX_INITIALIZER;
std::string output;

void write_char(char c) {
    pthread_mutex_lock(&output_mutex);
    std::cout << c << std::flush;
    output += c;
    pthread_mutex_unlock(&output_mutex);
}

// A — независимый
void* thread_a(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        computation();
        write_char('a');
    }
    return nullptr;
}

// B — независимый
void* thread_b(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        computation();
        write_char('b');
    }
    return nullptr;
}

// C — запускает D, E, F
void* thread_c(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        computation();
        write_char('c');
        sem_post(&sem_d);
        sem_post(&sem_e);
        sem_post(&sem_f);
    }
    return nullptr;
}

// D — после C, запускает G, K, M (2 раза)
void* thread_d(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        sem_wait(&sem_d);
        computation();
        write_char('d');
        if (i < 2) {
            sem_post(&sem_m_from_d); // Только два запуска m от D
        }
        sem_post(&sem_g);
        sem_post(&sem_k);
    }
    return nullptr;
}

// E — после C
void* thread_e(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        sem_wait(&sem_e);
        computation();
        write_char('e');
    }
    return nullptr;
}

// F — после C, но независимый
void* thread_f(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        sem_wait(&sem_f);
        computation();
        write_char('f');
    }
    return nullptr;
}

// G — после D
void* thread_g(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        sem_wait(&sem_g);
        computation();
        write_char('g');
        sem_post(&sem_h_start); // запускает H
    }
    return nullptr;
}

// K — после D
void* thread_k(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        sem_wait(&sem_k);
        computation();
        write_char('k');
    }
    return nullptr;
}

// H — после G, запускает I, ждёт I обратно
void* thread_h(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        sem_wait(&sem_h_start);
        computation();
        write_char('h');
        sem_post(&sem_i_done);    // запускает I
        sem_wait(&sem_h_start);   // ждёт окончания I
    }
    return nullptr;
}

// I — после H, запускает M один раз
void* thread_i(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        sem_wait(&sem_i_done);
        computation();
        write_char('i');
        if (i == 0) {
            sem_post(&sem_m_from_i); // Один запуск M от I
        }
        sem_post(&sem_h_start);     // отпускает H
    }
    return nullptr;
}

// M — два запуска от D, один от I
void* thread_m(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        bool done = false;
        while (!done) {
            if (sem_trywait(&sem_m_from_d) == 0 || sem_trywait(&sem_m_from_i) == 0) {
                done = true;
            } else {
                usleep(100);
            }
        }
        computation();
        write_char('m');
        sem_post(&sem_n); // запускает N
    }
    return nullptr;
}

// N — после M
void* thread_n(void*) {
    for (int i = 0; i < NUM_ITERATIONS; ++i) {
        sem_wait(&sem_n);
        computation();
        write_char('n');
    }
    return nullptr;
}

// API
const char* lab2_unsynchronized_threads() {
    return "abf";
}

const char* lab2_sequential_threads() {
    return "cde,gkh,imn";
}

unsigned int lab2_thread_graph_id() {
    return 13;
}

int lab2_init() {
    pthread_t threads[12];
// Инициализация семафоров
    sem_init(&sem_d, 0, 0);
    sem_init(&sem_e, 0, 0);
    sem_init(&sem_f, 0, 0);
    sem_init(&sem_g, 0, 0);
    sem_init(&sem_k, 0, 0);
    sem_init(&sem_h_start, 0, 0);
    sem_init(&sem_i_done, 0, 0);
    sem_init(&sem_m_from_d, 0, 0);
    sem_init(&sem_m_from_i, 0, 0);
    sem_init(&sem_n, 0, 0);

    pthread_create(&threads[0], nullptr, thread_a, nullptr);
    pthread_create(&threads[1], nullptr, thread_b, nullptr);
    pthread_create(&threads[2], nullptr, thread_c, nullptr);
    pthread_create(&threads[3], nullptr, thread_d, nullptr);
    pthread_create(&threads[4], nullptr, thread_e, nullptr);
    pthread_create(&threads[5], nullptr, thread_f, nullptr);
    pthread_create(&threads[6], nullptr, thread_g, nullptr);
    pthread_create(&threads[7], nullptr, thread_k, nullptr);
    pthread_create(&threads[8], nullptr, thread_h, nullptr);
    pthread_create(&threads[9], nullptr, thread_i, nullptr);
    pthread_create(&threads[10], nullptr, thread_m, nullptr);
    pthread_create(&threads[11], nullptr, thread_n, nullptr);

    for (auto& t : threads) {
        pthread_join(t, nullptr);
    }

    std::cout << std::endl;
    return 0;
}
