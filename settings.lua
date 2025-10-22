data:extend({
  {
    type = "string-setting",
    name = "a_ctts_with_passenger_condition",
    setting_type = "runtime-per-user",
    default_value = "inactivity",
    allowed_values = {"time", "inactivity", "full", "empty"}
  },
  {
    type = "int-setting",
    name = "b_ctts_with_passenger_wait_time",
    setting_type = "runtime-per-user",
    minimum_value = 1,
    default_value = 30
  },
  {
    type = "string-setting",
    name = "c_ctts_no_passenger_condition",
    setting_type = "runtime-per-user",
    default_value = "inactivity",
    allowed_values = {"time", "inactivity", "full", "empty"}
  },
  {
    type = "int-setting",
    name = "d_ctts_no_passenger_wait_time",
    setting_type = "runtime-per-user",
    minimum_value = 1,
    default_value = 30
  }
})
