#include <iostream>
#include <string>
#include <fstream>
#include <time.h>
#include <cmath>
#include <omp.h>

using namespace std;

// Метод для формирования входного массива
static void CreatingArray(int n, int ar[]) {
    srand(time(0));
    int r;
    for (int i = 0; i < n; i++) {
        ar[i] = rand() % 10000 + 1;
        r = rand() % 2;
        if (r == 0) {
            ar[i] *= -1;
        }
    }
}

// Метод для формирования строки вывода массива
static string OutputArray(int n, int ar[]) {
    string o = "";
    for (int i = 0; i < n; i++) {
        o += to_string(ar[i]);
        o += "\n";
    }
    return o;
}

// Многопоточный метод быстрой сортировки
static void QuickSort(int n, int* ar) {
    // Указатели в начало и в конец массива
    int i = 0;
    int j = n - 1;
    // Центральный элемент массива
    int mid = ar[n / 2];

    // Делим массив
    do {
        // Пробегаем элементы, ищем те, которые нужно перекинуть в другую часть
        // В левой части массива пропускаем элементы, которые меньше центрального по модулю
        while (abs(ar[i]) < abs(mid)) {
            i++;
        }
        // В правой части пропускаем элементы, которые больше центрального по модулю
        while (abs(ar[j]) > abs(mid)) {
            j--;
        }

        // Меняем элементы местами
        if (i <= j) {
            int tmp = ar[i];
            ar[i] = ar[j];
            ar[j] = tmp;
            i++;
            j--;
        }
    } while (i <= j);

    // Рекурсивные вызовы, если осталось, что сортировать
    #pragma omp task shared(ar) firstprivate(i, j)
    if (j > 0) {
        // Левый кусок
        QuickSort(j + 1, ar);
    }
    #pragma omp task shared(ar) firstprivate(i, j)
    if (i < n) {
        // Првый кусок
        QuickSort(n - i, &ar[i]);
    }
    #pragma omp taskwait
}

int main()
{
    // Считываем кол-во монахов
    cout << "Enter the number of monks:\n";
    int N;
    cin >> N;

    if (N < 1) {
        cout << "Incorrect number of monks";
        exit(0);
    }

    // Формируем входной массив
    int* arr = new int[N];
    CreatingArray(N, arr);

    // Выводим сформированный массив в файл
    ofstream o;
    o.open("energy.txt");
    if (o.is_open())
    {
        o << OutputArray(N, arr) << endl;
    }
    o.close();

    #pragma omp parallel shared(arr)
    {
        #pragma omp single nowait
        {
            // Сортируем массив
            QuickSort(N, arr);
        }
    }
    // Получаем максимальную энергию Ци
    int max = arr[N - 1];

    // Выводим победителя
    if (max < 0) {
        cout << "Guan-Yan is the winner. It's best result is " << abs(max) << " energy Zi.\n";
    }
    else {
        cout << "Guan-In is the winner. It's best result is " << abs(max) << " energy Zi.\n";
    }

    delete[] arr;
}
