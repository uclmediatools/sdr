proc select_security_info {win width height} {
    global prefs

    frame $win -borderwidth 3 -relief raised
    frame $win.setw -borderwidth 0 -height 1 -width $width
    pack $win.setw -side top

    label $win.l -text [tt "Security Configuration"]
    pack $win.l -side top

    frame $win.f
    pack $win.f -side top -fill both -expand true

    frame $win.f.l 
    pack $win.f.l -side right -fill both -expand true

    frame $win.f.l.pad -height 10
    pack $win.f.l.pad -side top 

    frame $win.f.l.f -borderwidth 2 -relief groove
    pack $win.f.l.f -side top -anchor w

    label $win.f.l.f.title -text "Encryption Group" -relief ridge \
	-borderwidth 2
    pack $win.f.l.f.title -side top -fill x -expand true
    

    label $win.f.l.f.l1 -text "Group name:"
    pack $win.f.l.f.l1 -side top -anchor w
    entry $win.f.l.f.e1 -width 40 -relief sunken -borderwidth 1 \
	-highlightthickness 0
    pack $win.f.l.f.e1 -side top -anchor w
    label $win.f.l.f.l2 -text "Key:"
    pack $win.f.l.f.l2 -side top -anchor w
    password $win.f.l.f.e2 -width 40 -relief sunken -borderwidth 1 \
	-variable tmpeditpass
    pack $win.f.l.f.e2 -side top -anchor w
    label $win.f.l.f.l2b -text "Re-type Key:"
    pack $win.f.l.f.l2b -side top -anchor w
    password $win.f.l.f.e2b -width 40 -relief sunken -borderwidth 1 \
	-variable tmpeditpass2
    pack $win.f.l.f.e2b -side top -anchor w
    label $win.f.l.f.l3 -text "Keyid:"
    pack $win.f.l.f.l3 -side top -anchor w
    entry $win.f.l.f.e3 -width 10 -relief sunken -borderwidth 1 \
	-highlightthickness 0
    pack $win.f.l.f.e3 -side top -anchor w

    frame $win.f.l.f.f 
    pack $win.f.l.f.f -side top -anchor w -fill x 
    button $win.f.l.f.f.b2 -text "Modify group" \
	-command "select_modify_key $win" -state disabled -pady 1
    pack $win.f.l.f.f.b2 -side left -anchor w -fill x -expand true
    button $win.f.l.f.f.b3 -text "Delete group" \
	-command "select_delete_key $win" -state disabled -pady 1
    pack $win.f.l.f.f.b3 -side left -anchor w -fill x -expand true

    frame $win.f.r 
    pack $win.f.r -side left -fill y -expand true

    label $win.f.r.l -text "Encryption Groups"
    pack $win.f.r.l -side top
    
    frame $win.f.r.f
    pack $win.f.r.f -side top

    listbox $win.f.r.f.lb -height 10 -width 20 -yscroll "$win.f.r.f.sb set" \
	-relief sunken -borderwidth 1 -selectmode single
    bind $win.f.r.f.lb <1> "%W selection clear 0 end;\
                            %W selection set \[%W nearest %y\];\
                            show_encryption_group $win"
    pack $win.f.r.f.lb -side left -fill x

    button $win.f.r.b -text "Add encryption group" -command register_key
    pack $win.f.r.b -side top -fill x

    global keylistbox 
    set keylistbox $win.f.r.f.lb
    scrollbar $win.f.r.f.sb -command "$win.f.r.f.lb yview" \
	-borderwidth 1
    pack $win.f.r.f.sb -side right -fill y
    $win.f.l.f.l1 configure -foreground [resource disabledForeground]
    $win.f.l.f.e1 configure -state disabled
    $win.f.l.f.l2 configure -foreground [resource disabledForeground]
    $win.f.l.f.e2 configure -state disabled
    $win.f.l.f.l2b configure -foreground [resource disabledForeground]
    $win.f.l.f.e2b configure -state disabled
    $win.f.l.f.l3 configure -foreground [resource disabledForeground]
    $win.f.l.f.e3 configure -state disabled
    $win.f.l.f.f.b2 configure -state disabled
    if {[get_passphrase]==""} {
	$win.f.r.l configure -foreground [resource disabledForeground]
	set keyfile "[resource sdrHome]/keys"
	if {[file exists $keyfile]&&([file size $keyfile]>0)} {
	    $win.f.r.b configure -state disabled
	}
    }
    
    frame $win.f2 -borderwidth 0 -relief flat -width 1 -height \
        [expr $height - [winfo reqheight $win]]
    pack $win.f2 -side top

    show_keys prefs
}

proc show_keys {win} {
    global keylist keylistbox
    catch {
	if {$win == "prefs"} {
	    set win $keylistbox
	}
	$win delete 0 end
	foreach keyname $keylist {
	    $win insert end "$keyname"
	}
    }
}

proc clear_keys {win} {
    global keylistbox
    catch {
	if {$win == "prefs"} {
	    set win $keylistbox
	}
	$win delete 0 end
    }
}

proc show_encryption_group {win} {
    set sel [$win.f.r.f.lb curselection]
    if {$sel==""} return
    set keyname [string trimright [$win.f.r.f.lb get $sel] "\n"]
    set tmp [find_key_by_name $keyname]
    set key [lindex $tmp 0]
    set keyid [lindex $tmp 1]
    
    $win.f.l.f.l1 configure -foreground [resource foreground]
    $win.f.l.f.e1 configure -state normal \
	-background [resource entryBackground]
    $win.f.l.f.l2 configure -foreground [resource foreground]
    $win.f.l.f.e2 configure -state normal \
	-background [resource entryBackground]
    $win.f.l.f.l2b configure -foreground [resource foreground]
    $win.f.l.f.e2b configure -state normal \
	-background [resource entryBackground]
    $win.f.l.f.l3 configure -foreground [resource foreground]
    $win.f.l.f.e3 configure -state normal \
	-background [resource entryBackground]
    $win.f.l.f.e1 delete 0 end
    $win.f.l.f.e1 insert 0 $keyname
    $win.f.l.f.e2.workaround set $key
    $win.f.l.f.e2b.workaround set $key
    $win.f.l.f.e3 delete 0 end
    $win.f.l.f.e3 insert 0 $keyid
    $win.f.l.f.f.b2 configure -state normal
    $win.f.l.f.f.b3 configure -state normal
}

proc select_delete_key {win} {
    set sel [$win.f.r.f.lb curselection]
    if {$sel==""} return
    set keyname [string trimright [$win.f.r.f.lb get $sel] "\n"]
    clear_prefs_keys
    delete_key $keyname
    $win.f.l.f.e1 delete 0 end
    $win.f.l.f.e2.workaround set ""
    $win.f.l.f.e2b.workaround set ""
    $win.f.l.f.e3 delete 0 end
    $win.f.l.f.f.b2 configure -state disabled
    $win.f.l.f.f.b3 configure -state disabled
    $win.f.l.f.l1 configure -foreground [resource disabledForeground]
    $win.f.l.f.e1 configure -state disabled -background [resource background]
    $win.f.l.f.l2 configure -foreground [resource disabledForeground]
    $win.f.l.f.e2 configure -state disabled -background [resource background]
    $win.f.l.f.l2b configure -foreground [resource disabledForeground]
    $win.f.l.f.e2b configure -state disabled -background [resource background]
    $win.f.l.f.l3 configure -foreground [resource disabledForeground]
    $win.f.l.f.e3 configure -state disabled -background [resource background]
}

proc select_modify_key {win} {
    global tmpeditpass tmpeditpass2 keylistbox
    set sel [$win.f.r.f.lb curselection]
    if {$sel==""} {
	bell
	prefs_help "No group to replace is selected in the encryption groups list"
	after 3000 prefs_help "\"\""
	return
    }
    set keyname [string trimright [$win.f.r.f.lb get $sel] "\n"]
    set newkeyname [$win.f.l.f.e1 get]
    if {[string compare $tmpeditpass $tmpeditpass2]!=0} {
	bell
	prefs_help "You must enter the same key twice"
	after 3000 prefs_help "\"\""
	return
    }
    if {[string length $tmpeditpass]<8} {
        bell
        prefs_help "Encryption keys must be at least 8 characters"
        after 3000 prefs_help "\"\""
        return
    }
    if {[$win.f.l.f.e3 get]<10000} {
        bell
        prefs_help "Key ID must be in the range 10000-429496297"
        after 3000 prefs_help "\"\""
        return
    }
    set newkeyid [$win.f.l.f.e3 get]
    clear_prefs_keys
    delete_key $keyname
    clear_prefs_keys
    add_key $tmpeditpass $newkeyname $newkeyid
    save_keys
    unset tmpeditpass
    unset tmpeditpass2
    $win.f.l.f.e1 delete 0 end
    $win.f.l.f.e2.workaround set ""
    $win.f.l.f.e2b.workaround set ""
    $win.f.l.f.e3 delete 0 end
    $win.f.l.f.f.b2 configure -state disabled
    $win.f.l.f.f.b3 configure -state disabled
    $win.f.l.f.l1 configure -foreground [resource disabledForeground]
    $win.f.l.f.e1 configure -state disabled -background [resource background]
    $win.f.l.f.l2 configure -foreground [resource disabledForeground]
    $win.f.l.f.e2 configure -state disabled -background [resource background]
    $win.f.l.f.l2b configure -foreground [resource disabledForeground]
    $win.f.l.f.e2b configure -state disabled -background [resource background]
    $win.f.l.f.l3 configure -foreground [resource disabledForeground]
    $win.f.l.f.e3 configure -state disabled -background [resource background]
    focus $keylistbox
}

proc register_key {} {
    catch {destroy .key}
    toplevel .key
    wm title .key "Sdr: Enter a new encryption key"
    frame .key.f -relief groove -borderwidth 2
    pack .key.f -side top

    label .key.f.l1 -text "Name of encryption group:"
    pack .key.f.l1 -side top -anchor w
    entry .key.f.e1 -width 60 -background [option get . entryBackground Sdr] \
	-highlightthickness 0
    pack .key.f.e1 -side top -anchor w

    frame .key.f.f
    pack .key.f.f -side top

    frame .key.f.f.l
    pack .key.f.f.l -side left
    label .key.f.f.l.l -text "Encryption key:"
    pack .key.f.f.l.l -side top -anchor w
    password .key.f.f.l.e -width 30 -variable tmpkey \
	 -background [option get . entryBackground Sdr]
    pack .key.f.f.l.e -side top -anchor w

    frame .key.f.f.r
    pack .key.f.f.r -side left
    label .key.f.f.r.l -text "Encryption key: (again)"
    pack .key.f.f.r.l -side top -anchor w
    password .key.f.f.r.e -width 30 -variable tmpkey2 \
	 -background [option get . entryBackground Sdr]
    pack .key.f.f.r.e -side top -anchor w

    label .key.f.l3 -text "Key identifier (should be numeric):"
    pack .key.f.l3 -side top -anchor w
    entry .key.f.e3 -width 10 -background [option get . entryBackground Sdr] \
	-highlightthickness 0
    pack .key.f.e3 -side top -anchor w

#    frame .key.f.f1
#    pack .key.f.f1 -side top
#    new_mk_session_admin .key.f.f1.admin new admin
    
    label .key.f.msg -borderwidth 1 -relief raised
    pack .key.f.msg -side top -fill x -expand true

    frame .key.f.f2
    pack .key.f.f2 -side top -fill x -expand true
    button .key.f.f2.ok -text "OK" -command submit_key
    pack .key.f.f2.ok -side left -fill x -expand true
    button .key.f.f2.cancel -text "Cancel" -command {destroy .key}
    pack .key.f.f2.cancel -side left -fill x -expand true
}

proc submit_key {} {
    global keylist tmpkey tmpkey2
    if {[string length [.key.f.e1 get]]<2} {
	bell
	.key.f.msg configure -text "You must configure a name for the encryption group"
	after 3000 "catch {.key.f.msg configure -text \"\"}"
	return
    }
    if {[string compare $tmpkey $tmpkey2]!=0} {
	.key.f.msg configure -text "You have not entered the same key twice"
	 after 3000 "catch {.key.f.msg configure -text \"\"}"
	return
    }

    if {[string length $tmpkey]<8} {
	bell
	.key.f.msg configure -text "Encryption keys must be at least 8 characters"
	after 3000 "catch {.key.f.msg configure -text \"\"}"
	return
    }
    if {[.key.f.e3 get]<10000} {
	bell
	.key.f.msg configure -text "Key ID must be in the range 10000-429496297"
	after 3000 "catch {.key.f.msg configure -text \"\"}"
	return
    }    
    add_key $tmpkey [.key.f.e1 get] [.key.f.e3 get]
    unset tmpkey
    catch {destroy .key}

    #this will get re-installed by the re-load that happens after saving...
    set keylist ""

    if {[get_passphrase] == ""} {
	enter_long_passphrase save
    } else {
	save_keys
    }
}

proc enter_passphrase {} {
    global ifstyle
    if {$ifstyle(labels)=="long"} {
	enter_long_passphrase load
    } else {
	pack .f4 -side top -fill both -expand true -after .f2
	enter_short_passphrase .f5 .f4
    }
}

proc enter_long_passphrase {mode} {
    catch {destroy .pass}
    toplevel .pass
    wm title .pass "Sdr: Enter the pass phrase for your key file"
    frame .pass.f -relief groove -borderwidth 2
    pack .pass.f -side top
    
    message .pass.f.m -text "You must enter a passphrase to be able to load and save the keys for encrypted sessions." -aspect 300
    pack .pass.f.m -side top

    password .pass.f.e -width 40 \
	-background [option get . entryBackground Sdr] -variable tmppass

    pack .pass.f.e -side top
    bind .pass.f.e <Key-Return> "submit_pass .pass $mode .pass.f.msg \"\""

    label .pass.f.msg -borderwidth 1 -relief raised
    pack .pass.f.msg -side top -fill x -expand true

    frame .pass.f.f2
    pack .pass.f.f2 -side top -fill x
    button .pass.f.f2.ok -text "OK" \
	-command "submit_pass .pass $mode .pass.f.msg \"\""
    pack .pass.f.f2.ok -side left
    button .pass.f.f2.cancel -text "Cancel" -command {destroy .pass}
    pack .pass.f.f2.cancel -side left
}

proc enter_short_passphrase {win after} {
    frame $win -relief groove -borderwidth 2
    pack $win -side top -after $after -fill x
    
    set str "Enter passphrase to view encrypted sessions:"
    label $win.msg -borderwidth 1 -text $str\
	-font [option get . infoFont Sdr] -anchor nw
    pack $win.msg -side top -fill x -expand true
    frame $win.f
    pack $win.f -side top -fill x -expand true
#    entry $win.f.e -width 30 -font [option get . infoFont Sdr] \
	-background [option get . entryBackground Sdr]
    password $win.f.e -width 30 -font [option get . infoFont Sdr] \
        -background [option get . entryBackground Sdr] -variable tmppass \
	-command "submit_pass $win load $win.msg \"$str\""
    pack $win.f.e -side left -fill x -expand true
#    bind $win.f.e <Key-Return> "submit_pass $win load"
    


}

proc submit_pass {win mode msgwin str} {
    global tmppass
#    if {[string length [$win.f.e get]]<8} \{
    if {([string length $tmppass]<8)&&($mode == "save")} {
	bell
	$msgwin configure -text "Please choose a longer pass phrase"
	after 5000 catch {$win.f.msg configure -text $str}
	return
    }
#    set_passphrase [$win.f.e get]
    set_passphrase $tmppass
    if {$mode == "save"} {
	save_keys
    } elseif {$mode == "load"} {
	$msgwin configure -text "Checking passphrase"
	update
	if {[load_keys]==1} {
	    $msgwin configure -text "Loading cached sessions"
	    update
	    load_from_cache
	    $msgwin configure -text "$str"
	} else {
	    $win.f.e.workaround set ""
	    bell
	    $msgwin configure -text "Pass phrase incorrect"
	    set tmppass ""
	    after 3000 "catch {$msgwin configure -text \"$str\"}"
	    return
	}
    }
    catch {destroy $win}
}

set keylist ""

proc clear_prefs_keys {} {
    global keylist
    set keylist ""
    show_keys prefs
}

proc install_key {keyname} {
    global keylist
    lappend keylist $keyname
    show_keys prefs
}

proc new_mk_session_security {win aid} {
    global ldata security keylist
    frame $win -relief groove -borderwidth 2
    pack $win -side left -fill both -expand true
    checkbutton $win.b1 -text "Encryption" -variable security\
	-highlightthickness 0 -justify l \
	-relief flat -onvalue private -offvalue public \
	-command "toggle_security $win"
    if {([string compare $aid "new"]!=0)&&($ldata($aid,key)!="")} {
	set security private
    } else {
	set security public
    }

    tixAddBalloon $win.b1 Button [tt "Select \"Encryption\" to announce your session to a private group of people who share one of your encryption keys."]
    if {$keylist==""} {
	$win.b1 configure -state disabled
	set security public
    }
    hlfocus $win.b1
    pack $win.b1 -side top -anchor nw

    frame $win.f
    pack $win.f -side top -fill both -expand true
    listbox $win.f.lb -width 15 -height 4 -yscroll "$win.f.sb set" \
	-borderwidth 1 -highlightthickness 0
    pack $win.f.lb -side left -fill both -expand true
    scrollbar $win.f.sb -command "$win.f.lb yview" -borderwidth 1 \
	 -highlightthickness 0
    pack $win.f.sb -side right -fill y
    toggle_security $win
    if {([string compare $aid "new"]!=0)&&($ldata($aid,key)!="")} {
	update
	global keylist
	set ctr 0
	foreach keyname $keylist {
	    set key [lindex [find_key_by_name $keyname] 0]
            if {[string compare $key $ldata($aid,key)]==0} {
		     $win.f.lb selection set $ctr
		     break
		 }
	    incr ctr
        }

    }
    proc get_new_session_key {} [format {
	%s.f.lb get [lindex [%s.f.lb curselection] 0]
    } $win $win ]
}

proc toggle_security {win} {
    global security
    if {$security=="public"} {
	clear_keys $win.f.lb
    } else {
	show_keys $win.f.lb
    }
}


# Set up the order of items in the preferences window
set prefprocs "show ifstyle tools web pers security"

proc pref_security {cmd {arg1 {}} {arg2 {}} {arg3 {}}} {
    global prefs

    switch $cmd {
	copyin		{
			}

	copyout		{
			}

	defaults	{
			}

	create		{
			select_security_info $arg1 $arg2 $arg3
			return "Security"
			}

        balloon         {
                        return "Specify encryption keys for private sessions"
		        }

	save		{
			}
    }
}
