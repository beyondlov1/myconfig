#! /bin/bash

function get_screen_width()
{
    local width_path=/tmp/screen_width
    if test -f $width_path
    then
        echo $(cat $width_path)
        return 0
    fi
    local width=$(xrandr | grep "*+" | awk '{print $1}' | awk -F'x' '{print $1}')
    echo $width > $width_path
    echo $width
    return 0
}

function get_screen_height()
{
    local  height_path=/tmp/screen_height
    if test -f $height_path
    then
        echo $(cat $height_path)
        return 0
    fi
    local height=$(xrandr | grep "*+" | awk '{print $1}' | awk -F'x' '{print $2}')
    echo $height > $height_path
    echo $height
    return 0
}


get_screen_width
get_screen_height