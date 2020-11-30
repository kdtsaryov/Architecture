#include <iostream>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <vector>
#include <random>
#include <ctime>

#define MAXITER 5 // Максимальное кол-во итераций

using namespace std;

mutex lockPrint;
mutex lockHoney;
condition_variable potFull1;
condition_variable potFull2;
bool notified1;
bool notified2 = true;
int cnt;
int start;

// Функция для потока пчелы
void beeThreadFunction(int id, int H, int& a, mt19937& generator)
{
    // Пчёлы бесконечно собирают мёд
    while (true) {
        {
            unique_lock<mutex> locker(lockPrint);
            cout << "[Время " << time(NULL) - start << "]\t" << "Пчела " << id
                << " начала собирать мёд.\tНаполненность горшка [" << a << "/" << H << "]\n";
        }
        // Симуляция сборки меда
        this_thread::sleep_for(chrono::seconds(1 + generator() % 5));
        {
            unique_lock<mutex> locker(lockPrint);
            cout << "[Время " << time(NULL) - start << "]\t" << "Пчела " << id
                << " собрала глоток мёда.\n";
        }
        this_thread::sleep_for(chrono::seconds(1));
        {
            unique_lock<mutex> locker(lockHoney);
            while (!notified2) potFull2.wait(locker);
            // Если медведь уже поел 6 раз, то заканчиваем собирать мёд
            if (cnt == MAXITER) return;
            a++;
            {
                unique_lock<mutex> locker(lockPrint);
                cout << "[Время " << time(NULL) - start << "]\t" << "Пчела " << id
                    << " положила мёд в горшок.\tНаполненность горшка [" << a << "/" << H << "]\n";
            }
            this_thread::sleep_for(chrono::seconds(1));
            // Если горшок наполнился
            if (a == H) {
                {
                    unique_lock<mutex> locker(lockPrint);
                    cout << "[Время " << time(NULL) - start << "]\t" << "Пчела " << id << " разбудила медведя.\n";
                }
                // Сообщаем медведю
                notified1 = true;
                potFull1.notify_one();
                notified2 = false;
                this_thread::sleep_for(chrono::seconds(1));
            }
        }        
    }
}

// Функция для потока медведя
void bearThreadFunction(int& a)
{
    // Ограничение в 6 итераций
    while (cnt < MAXITER) {
        unique_lock<mutex> locker(lockHoney);
        while (!notified1) potFull1.wait(locker);
        {
            unique_lock<mutex> locker(lockPrint);
            cout << "\n[Время " << time(NULL) - start << "]\t" << "Медведь проснулся и начал есть мёд.\n\n";
        }
        this_thread::sleep_for(chrono::seconds(3));
        a = 0;
        {
            unique_lock<mutex> locker(lockPrint);
            cout << "\n[Время " << time(NULL) - start << "]\t" << "Медведь доел мёд и уснул.\n\n";
        }
        this_thread::sleep_for(chrono::seconds(1));
        cnt++;
        // Когда медведь всё съел, сообщаем всем пчёлам
        notified2 = true;
        potFull2.notify_all();
        notified1 = false;
    }
}

int main()
{
    setlocale(LC_ALL, "Russian");
    // Кол-во пчёл
    int n;
    // Вместимость горшка
    int H;
    // Текущая наполненность горшка
    int honeyPot = 0;

    cout << "Введите количество пчёл в лесу:\n";
    cin >> n;
    if (n < 1) {
        cout << "Неравильное количество пчёл.\n";
        return -1;
    }
    cout << "Введите вместимость горшка (в глотках):\n";
    cin >> H;
    if (H < 1) {
        cout << "Неравильное количество глотков.\n";
        return -1;
    }

    // Генератор случайных чисел
    mt19937 generator((unsigned int)std::chrono::system_clock::now().time_since_epoch().count());
    start = time(NULL);

    // Запускаем потоки
    thread bearThread(bearThreadFunction, ref(honeyPot));
    vector<thread> threads;
    for (int i = 0; i < n; i++)
        threads.push_back(thread(beeThreadFunction, i + 1, H, ref(honeyPot), ref(generator)));

    for (auto& t : threads)
        t.join();
    bearThread.join();
}
