#include<iostream>
using namespace std;

int main(){
    int unsort[50],i,j, temp, n;
    cout << "Enter the number of elements in the arrar: ";
    cin >> n;
    cout << "\n";
    cout << "Enter the unsorted elements of the array: ";
    for(i=0;i<n;i++){
        cin >> unsort[i];
    }
    cout << "Unsorted array is: " << "\n";
    for(i=0;i<n;i++){
        cout << unsort[i] << "\t";
    }
    cout << "\n";
    for(i=0;i<n;i++){
        for(j=0;j<n-i;j++){
            if(unsort[j]>unsort[j+1]){
                temp = unsort[j];
                unsort[j] = unsort[j+1];
                unsort[j+1] = temp;
            }
        }
    }
    cout << "Sorted array is: \n";
    for(i=0;i<n;i++){
        cout << unsort[i] << "\t";
    }

}