-- The mod settings internal names are prefixed to enforce an ordering in the mod settings menu.

-- Changing train behavior
script.on_event(defines.events.on_train_schedule_changed, function(event)

	-- If the schedule was changed by a script like this one don't change it again.
	if event.player_index ~= nil then
		local train = event.train
		local schedule = train.get_schedule()
		
		-- Factorio uses nil instead of a zero-length array, so we need to check for null safety
		if schedule ~= nil then
            --
            -- Factorio 2.0 enhanced compatability notes:
            --
            --  After 2.0 there is a distinction between the TrainSchedule (https://lua-api.factorio.com/latest/concepts/TrainSchedule.html) and the LuaSchedule (https://lua-api.factorio.com/latest/classes/LuaSchedule.html) which are offered from different methods/variables in LuaTrain (https://lua-api.factorio.com/latest/classes/LuaTrain.html)
            --
            -- Historically this mod used TrainSchedule, at least on core v2.0.66 assigning the TrainSchedule booted the train out of any group it was in AND seemed to prevent interrupt stations from being set.
            -- This section of code has been updated in CTTS v0.3.0 to use the LuaSchedule, which allowed for scripted edits of stations in trains in groups and out of groups without further issues.
            --  

			local schedule_records = schedule.get_records()
			local player = game.players[event.player_index]
			
			local with_passenger_condition = settings.get_player_settings(player)["a_ctts_with_passenger_condition"].value
			local with_passenger_time = settings.get_player_settings(player)["b_ctts_with_passenger_wait_time"].value
			
			local no_passenger_condition = settings.get_player_settings(player)["c_ctts_no_passenger_condition"].value
			local no_passenger_time = settings.get_player_settings(player)["d_ctts_no_passenger_wait_time"].value
				

            local num_records_in_schedule = #(schedule_records)
			for record_index=0, num_records_in_schedule, 1  do
                local record = schedule_records[record_index]
				-- Only update the temporary train stops that AREN'T created by interrupt rules
				if ( (record ~=nil) and ((record.temporary ~=nil) and record.temporary) and ((record.created_by_interrupt == nil) or (record.created_by_interrupt == false))) then
                    --local record_string = serpent.block(record)
                    --game.print(record_string)

                    local record_index_table = {schedule_index = record_index}

                    --Remove all existing conditions from the temporary stop
                    local num_conditions = #(record.wait_conditions)
                    for condition_index = 1, (num_conditions+1), 1 do
                        schedule.remove_wait_condition(record_index_table, condition_index)
                    end


                
                    --Add in new conditions based on the state of the passenger being in the train.
					--Passenger present at time of request
					if #(train.passengers) > 0 then
                        local with_passengers_condition_part_one = {
                                compare_type = "or",
								type = with_passenger_condition,
								ticks = with_passenger_time*60
							}

                        local with_passengers_condition_part_two = {
                            type = "passenger_present",
							compare_type = "and"
						}
						
                        schedule.add_wait_condition(record_index_table, 1, with_passenger_condition)
                        schedule.change_wait_condition(record_index_table, 1, with_passengers_condition_part_one)
                        schedule.change_wait_condition(record_index_table, 2, with_passengers_condition_part_two)

					--Passenger not present at time of request
					else
                        local no_passengers_condition_part_one = {
                                compare_type = "or",
								type = no_passenger_condition,
								ticks = no_passenger_time*60
							}

                        local no_passengers_condition_part_two = {
                            type = "passenger_present",
							compare_type = "or"
						}
						

                        schedule.add_wait_condition(record_index_table, 1, no_passenger_condition)
                        schedule.change_wait_condition(record_index_table, 1, no_passengers_condition_part_one)
                        schedule.change_wait_condition(record_index_table, 2, no_passengers_condition_part_two)

					end
				end
			end

            	--Factorio docs require the train schedule object get overwritten to work
		        -- https://lua-api.factorio.com/latest/LuaTrain.html#LuaTrain.schedule
                -- Legacy train.schedule = schedule assignment occured here.
		end
	end
end)














