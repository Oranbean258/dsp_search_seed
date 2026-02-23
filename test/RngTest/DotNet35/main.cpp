#include <iostream>
#include <cstdint>
#include <thread>
#include <vector>
#include <chrono>
#include <functional>
#include <numeric>
#include "DotNet35Random.hpp"

static int32_t g_maxRngConstructNum = 20;

void RecursiveWork(int32_t seed, int32_t depth, int64_t& result)
{
    if (depth <= 0) {
        return;
    }
    DotNet35Random rng(seed);
    for (int32_t i = 0; i < 6; ++i) {
        result += rng.Next();
    }
    RecursiveWork(seed, depth - 1, result);
}

void RecursiveWorkWithCache(int32_t seed, int32_t depth, int64_t& result)
{
    if (depth <= 0) {
        return;
    }

    DotNet35Random rng = DotNet35RandomManager::GetInstance(seed);
    for (int32_t i = 0; i < 6; ++i) {
        result += rng.Next();
    }

    RecursiveWorkWithCache(seed, depth - 1, result);
}

void ThreadTask(int32_t start, int32_t end, bool useCache, int64_t& result)
{
    int64_t tmp = 0;
    for (int32_t i = start; i < end; ++i) {
        if (useCache) {
            RecursiveWorkWithCache(i, g_maxRngConstructNum, tmp);
        } else {
            RecursiveWork(i, g_maxRngConstructNum, tmp);
        }
    }
    result = tmp;
}

int32_t main(int32_t argc, char** argv)
{
    int32_t start = 0;
    int32_t end = 11111111;
    int32_t threadNum = 20;
    int64_t resultWithOutCache = 0;
    int64_t resultWithCache = 0;

    auto runTest = [&](bool useCache, const std::string& label)
    {
        std::vector<std::thread> threads;
        std::vector<int64_t> results(threadNum, 0);
        int32_t tasksPerThread = (end - start) / threadNum;

        auto startTime = std::chrono::high_resolution_clock::now();

        for (int32_t t = 0; t < threadNum; ++t) {
            int32_t s = start + t * tasksPerThread;
            int32_t e = (t == threadNum - 1) ? end : s + tasksPerThread;
            threads.emplace_back(ThreadTask, s, e, useCache, std::ref(results[t]));
        }

        for (auto& th : threads) {
            th.join();
        }

        auto endTime = std::chrono::high_resolution_clock::now();
        int64_t ret = std::accumulate(results.begin(), results.end(), 0ULL);
        std::chrono::duration<double> diff = endTime - startTime;
        printf("%s execute time: %.6fs\n", label.c_str(), diff.count());
        return ret;
    };

    printf("Test duration: %d-%d, rng construct num: %d\n", start, end, g_maxRngConstructNum);
    resultWithOutCache = runTest(false, "--without cache");
    resultWithCache = runTest(true, "--with cache");

    if (resultWithOutCache != resultWithCache) {
        printf("Check failed!\n");
    } else {
        printf("Check passed.\n");
    }
    return 0;
}