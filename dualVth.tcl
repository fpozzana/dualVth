proc dualVth {args} {
	parse_proc_arguments -args $args results
	set savings $results(-savings)
	set args $savings

#######################################################proc cells swapping no resizing#########################################################

proc cells_swapping_no_resizing {var_list type} {
	foreach input_cell $var_list {
		set cell [get_cell $input_cell]
		set ref_name [get_attribute $cell ref_name]
		#puts "original ref_name --> $ref_name"
		set cell_name_split_type [split $ref_name "_"]
		set cell_name_split_size [split $ref_name "X"]
		set original_size  [lindex $cell_name_split_size end]
		set cell_area [get_attribute $cell area]
		#puts "original area --> $cell_area"
		#puts "original size --> $original_size"

		if {[regexp {LVT} $type]} {	
			if {[regexp {LH} $cell_name_split_type]} {
				#puts "trying to change from HVT to LVT the gate"
				foreach_in_collection alternative_cell [get_alternative_lib_cells $input_cell] {
					set alternative_cell_full_name [get_attribute $alternative_cell full_name]
					set alternative_cell_area [get_attribute $alternative_cell area]
					set alternative_cell_full_name_split_type [split $alternative_cell_full_name "_"]
					set alternative_cell_full_name_split_size [split $alternative_cell_full_name "X"]
					set size_new_cell [lindex $alternative_cell_full_name_split_size end]
					
					if {[regexp {LL} $alternative_cell_full_name_split_type]} {
						if {[expr [expr $cell_area - $alternative_cell_area] == 0]} {
							if {[expr [expr $original_size - $size_new_cell] == 0]} {
								set new_cell_name $alternative_cell_full_name
								set new_cell_area $alternative_cell_area
								set new_cell_size $size_new_cell
								#puts "now I can change the cell from HVT to LVT"
								size_cell $input_cell $alternative_cell_full_name
								#puts "new cell ref_name --> $new_cell_name"
								#puts "new cell area --> $new_cell_area"
								#puts "new cell size --> $new_cell_size"
								break
							}
						}
					}
				}
			}

		}

		if {[regexp {HVT} $type]} {	
			if {[regexp {LL} $cell_name_split_type]} {
				#puts "trying to change from LVT to HVT the gate"
				foreach_in_collection alternative_cell [get_alternative_lib_cells $input_cell] {
					set alternative_cell_full_name [get_attribute $alternative_cell full_name]
					set alternative_cell_area [get_attribute $alternative_cell area]
					set alternative_cell_full_name_split_type [split $alternative_cell_full_name "_"]
					set alternative_cell_full_name_split_size [split $alternative_cell_full_name "X"]
					set size_new_cell [lindex $alternative_cell_full_name_split_size end]
					
					if {[regexp {LH} $alternative_cell_full_name_split_type]} {
						if {[expr [expr $cell_area - $alternative_cell_area] == 0]} {
							if {[expr [expr $original_size - $size_new_cell] == 0]} {
								set new_cell_name $alternative_cell_full_name
								set new_cell_area $alternative_cell_area
								set new_cell_size $size_new_cell
								#puts "now I can change the cell from LVT to HVT"
								size_cell $input_cell $alternative_cell_full_name
								#puts "new cell ref_name --> $new_cell_name"
								#puts "new cell area --> $new_cell_area"
								#puts "new cell size --> $new_cell_size"
								break
							}
						}
					}
				}
			}

		}
	
	}
}


#################################################################PROC EXPLORE MERIT############################################################

proc explore_merit {} {

	set original_list {}
	set original_leakage_list {}
	set slack_list {}
	set new_list {}
	set new_leakage_list {}
	set merit_index_list {}
	set ordered_list {}



	set original_cells [get_cells]

	foreach_in_collection cells $original_cells {
	
		set full_name [get_attribute $cells full_name]
		#puts "$full_name"
		lappend original_list $full_name
		set leakage [get_attribute $cells leakage_power]
		#puts "$leakage"	
		lappend original_leakage_list $leakage
		
		set pins [get_pins -of_objects $cells]
		set out_pin [get_pin -filter {direction == out} $pins]
		
		set slack [get_attribute $out_pin max_slack]
		#puts "slack is --> $slack"
		lappend slack_list $slack

		cells_swapping_no_resizing $full_name HVT

	}

	set new_cells [get_cells]

	foreach_in_collection cell $new_cells {
	
		set new_leakage [get_attribute $cell leakage_power]
		#puts "$new_leakage"
		lappend new_leakage_list $new_leakage

	}



	#puts "--------------------------------original cell ref name--------------------------"
	#puts "$original_list"
	#puts "lenght of original list is  --> [llength $original_list]"
	#puts "--------------------------------original cell leakage---------------------------"
	#puts "$original_leakage_list"
	#puts "original leakage list lenght is --> [llength $original_leakage_list]"
	#puts "---------------------------------original cells slack---------------------------"
	#puts "$slack_list"
	#puts "slack list lenght is --> [llength $slack_list]"
	#puts "--------------------------------new cell leakage--------------------------------"
	#puts "$new_leakage_list"
	#puts "new leakage list lenght is --> [llength $new_leakage_list]"
	#puts "--------------------------------------------------------------------------------"

	set var_list {}
	set index 0

	foreach i $slack_list {
		set merit [expr 1 / [expr $i * [expr [lindex $original_leakage_list $index] - [lindex $new_leakage_list $index]]]]	
		lappend var_list "[lindex $original_list $index] $merit"		
		incr index
	}

	#puts "---------------------------------final list unsorted----------------------------"
	#puts "$var_list"
	#puts "final list lenght is --> [llength $var_list]"
	#puts "--------------------------------------------------------------------------------"

	set var_list [lsort -decreasing -index 1 $var_list]

	#puts "---------------------------------final list sorted------------------------------"
	#puts "$var_list"
	#puts "final list lenght is --> [llength $var_list]"
	#puts "--------------------------------------------------------------------------------"

	return $var_list

}

################################################################################################################################################

	set design [get_design]							
	set leakage_all_LVT [get_attribute $design leakage_power]		

	if {[expr $args == 0]} {
		puts "no optimization done"
	} elseif {[expr $args == 1]} {
		set cell_collection [get_cells]
		foreach_in_collection cell $cell_collection {
			set name [get_attribute $cell full_name]
			cells_swapping_no_resizing $name HVT
		}		
		set new_design [get_design]
		set new_leakage [get_attribute $new_design leakage_power]
		puts "all cells have been swapped"		
		#puts "former leakage --> $leakage_all_LVT"
		#puts "new leakage --> $new_leakage"
		#puts "optimization value --> $args"
		set gain [expr [expr $leakage_all_LVT - $new_leakage] / $leakage_all_LVT]
		puts "my savings is $gain ,while the original savings was $savings"
	} else {
		set ordered_list {}
		set ordered_list [explore_merit]				
		#puts "I've now finished ordering my list"
		#puts "--------------------------------------------------------------------------------"		
		#puts "this is my ordered list"
		#puts "--------------------------------------------------------------------------------"
		#puts $ordered_list	
		#puts "--------------------------------------------------------------------------------"	
		set item 0
		foreach aux $ordered_list {		
			set new_design [get_design]
			set new_leakage [get_attribute $new_design leakage_power]
			set gain [expr [expr $leakage_all_LVT - $new_leakage] / $leakage_all_LVT]
			if {[expr $gain - $savings] > 0} {
				cells_swapping_no_resizing [lindex $ordered_list $item 0] LVT
				incr item
			} else {
				#puts "now I have to swap the last cell"
				cells_swapping_no_resizing [lindex $ordered_list [expr $item - 1] 0] HVT
				set new_design [get_design]
				set new_leakage [get_attribute $new_design leakage_power]
				set gain [expr [expr $leakage_all_LVT - $new_leakage] / $leakage_all_LVT]
				puts "my savings is $gain ,while the original savings was $savings"
				break
			}
		}
	}

	return
}

define_proc_attributes dualVth \
-info "Post-Synthesis Dual-Vth cell assignment" \
-define_args \
{
	{-savings "minimum % of leakage savings in range [0, 1]" lvt float required}
}
