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