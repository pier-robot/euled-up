#include <iostream>

#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif

#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <vector>
#include "scene.h"

using namespace std;

void write_out(Vector2D input){
    cout.write(reinterpret_cast<const char*>(&input.x), sizeof input.x);
    cout.write(reinterpret_cast<const char*>(&input.y), sizeof input.y);
}

int main() {

    auto main_scene = Scene(10);
    unsigned int boid_no = main_scene.get_boid_no();

    // setting stream to binary for visualiser 
    int result =_setmode( _fileno( stdout ), _O_BINARY );
    if( result == -1 ) return 1;

    // "reinterpret_cast converts between types by reinterpreting the underlying bit pattern"
    cout.write(reinterpret_cast<const char*>(&boid_no), sizeof boid_no);

    while (true)
    {
        main_scene.recalc_scene();
        for(auto it : main_scene.boid_list) {
            write_out(it.position);
            write_out(it.velocity);
        }
        cout.flush();    
        Sleep(1.666);
    }
    return 0;
}