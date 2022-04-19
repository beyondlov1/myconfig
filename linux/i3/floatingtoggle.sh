#!/bin/bash

function get_active_win()
{
    # get id of the focused window
    local active_win_id=$(xprop -root | grep '^_NET_ACTIVE_W' | awk -F'# 0x' '{print $2}' | awk -F',' '{print $1}')
    for((j=0;j<7-${#active_win_id};j++));
    do
        active_win_id="0"${active_win_id}
    done

    active_win_id="0x0${active_win_id}"
    echo $active_win_id
    return 0
}

function get_win_geometry()
{
    local win=$1
    echo $(wmctrl -G -l | grep $win | awk '{print $3","$4","$5","$6 }')
    return 0
}

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


op=$1

# get id of the focused window
active_win_id=$(get_active_win)
active_win_geometry=$(get_win_geometry $active_win_id )
active_win_item=$active_win_id:$active_win_geometry
echo $active_win_item
new_floating_wins=()
touch  ~/.config/i3/floating.win
floating_wins=$(cat ~/.config/i3/floating.win)
floating=0
for floating_win in $floating_wins
do
    id=$(echo ${floating_win} | cut -d ':' -f 1 )
    if test $active_win_id = $id 
    then
       floating=1
       old_active_floating_item=${floating_win}
       continue 
    fi
    new_floating_wins[${#new_floating_wins[*]}]=${floating_win}
done

if test 0 -eq $floating 
then
   new_floating_wins[${#new_floating_wins[*]}]=${active_win_item} 
fi

if test "tf" = $op 
then  
    if test 1 -eq $floating 
    then        
        i3-msg floating disable    
    else
        x=$2
        y=$3
        w=$4
        h=$5
        #i3-msg "floating enable; sticky enable; resize set 700 650;  move absolute position 1630 100"
        i3-msg "floating enable; sticky enable; resize set $w $h;  move absolute position $x $y"
    fi        
    echo ${new_floating_wins[*]} > ~/.config/i3/floating.win 
fi

if test "tfr" = $op 
then  
    if test 1 -eq $floating 
    then        
        i3-msg floating disable    
    else
        sw=$(get_screen_width)
        sh=$(get_screen_height)
        x=$(echo "scale=0;$2*$sw/1" | bc -l)
        y=$(echo "scale=0;$3*$sh/1" | bc -l)
        w=$(echo "scale=0;$4*$sw/1" | bc -l)
        h=$(echo "scale=0;$5*$sh/1" | bc -l)
        i3-msg "floating enable; sticky enable; resize set $w $h;  move absolute position $x $y"
    fi        
    echo ${new_floating_wins[*]} > ~/.config/i3/floating.win 
fi

if test "k" = $op 
then
    i3-msg kill
    echo ${new_floating_wins[*]} > ~/.config/i3/floating.win 
fi


if test "fr" = $op 
then
    if test 1 -eq $floating 
    then
        i3-msg focus mode_toggle  
    else
        i3-msg focus right 
    fi
fi

if test "fl" = $op 
then
    if test 1 -eq $floating 
    then
        i3-msg focus mode_toggle  
    else
        i3-msg focus left
    fi
fi

if test "fu" = $op 
then
    if test 1 -eq $floating 
    then
        i3-msg focus left
    else
        i3-msg focus up 
    fi
fi

if test "fd" = $op 
then
    if test 1 -eq $floating 
    then
        i3-msg focus right
    else
        i3-msg focus down
    fi
fi

if test "fmt" = $op 
then
    if test 1 -eq $floating 
    then
        sw=$(get_screen_width)
        sh=$(get_screen_height)
        x=$(echo "scale=0;$sw/1-100" | bc -l)
        y=$(echo ${old_active_floating_item} | cut -d ':' -f 2 | cut -d ',' -f 2)
        echo $x $y
        i3-msg move absolute position $x $y
        i3-msg focus mode_toggle
    else
        i3-msg focus mode_toggle
        i3-msg move position center
    fi
fi

if test "move" = $op 
then
   for floating_win in $floating_wins
   do
        id=$(echo ${floating_win} | cut -d ':' -f 1 )
        if test $active_win_id = $id 
        then
            floating=1
            new_floating_wins[${#new_floating_wins[*]}]=$active_win_item 
            continue 
        fi
        new_floating_wins[${#new_floating_wins[*]}]=${floating_win}
    done 
    echo ${new_floating_wins[*]} > ~/.config/i3/floating.win 
fi