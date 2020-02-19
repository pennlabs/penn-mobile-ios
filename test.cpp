#include <iostream>

using namespace std;

int main() {
    int n = 10;
    int count = 0;

    for(int i = 1; i <= n/2; i*=2){
	for(int j = i; j < 4*i; j*=2) {
	    count++;
	}
    }

    cout << count << endl;
}
