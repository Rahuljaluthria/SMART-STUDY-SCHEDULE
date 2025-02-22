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
        for(j=i+1;j<n;j++){
            if(unsort[i]>unsort[j]){
                temp = unsort[i];
                unsort[i] = unsort[j];
                unsort[j] = temp;
            }
        }
    }
    cout << "Sorted array is: \n";
    for(i=0;i<n;i++){
        cout << unsort[i] << "\t";
    }
}