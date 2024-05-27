---@meta

---MWWSE
---@param t any
---@param visited any
---@return table
---deep clones a table, table and all sub tables
---will copy values and no references to original table
function DEEP_CLONE(t, visited) end

--workaround because i hate using vector.pack unpack
--should probably not use this
function TO_VECTOR(_table) end

--workaround because i hate using vector.pack unpack
--should probably not use this
function VEC_TO_TABLE(_table) end

---MWWSE
---@param var any
---@return integer
---why not just use math.round() we will never know
function ROUND(var) end

---MWWSE
---@param var number
---@return integer
function ROUND_TWO_DECIMAL(var) end

---MWWSE
---@param var any
---@return integer
---Rounds vector to two decimal places
function ROUND_VECTOR(a) end

---MWWSE
---@param input Vector3|table
---@return Vector3|table
---Rounds vector or table to one decimal place
function ROUND_POINT_OR_VECTOR(input) end

---MWWSE
---@param a table
---@param b table
---@return number
---returns the distance between two points that are either tables or vectors
function DISTANCE_POINT_OR_VECTOR(a, b) end

---MWWSE
---@param var any
---@return integer
---Rounds vector
function ROUND_VECTOR_TO_INT(a) end

---MWWSE
---@param var any
---@return integer
---rounds matrix to two decimal places
function ROUND_MATRIX(cm) end

---MWWSE
---@param a table
---@param b table
---@return table
---returns the point inbetween two points
function AVERAGE_POINT(a, b) end

---MWWSE
---@param a Vector3
---@param b Vector3
---@return Vector3
--returns the vector inbetween two vectors
function AVERAGE_VECTOR(a, b) end

---MWWSE
---returns the avrage of a list of points
---@param points any
---@return nil
---Returns the average of a list of points in either table or list of vector3
function GET_AVERAGE_OF_POINTS(points) end

---MWWSE
---@param a table
---@param b table
---@return number
---returns the distance between two points stored in tables
---DEPRECATED
function DISTANCE_TABLE(a, b) end

---MWWSE
---@param a table|Vector2
---@param b table|Vector2
---@return number
---returns the distance between two points or vector2
function DISTANCE(a, b) end

---MWWSE
--- Calculate the distance between two points in 3D space.
---@param a table
---@param b table
---@return number
function DISTANCE_TABLE_3D(a, b) end

---MWWSE
---returns a new table trated as vector that has moved towards b by x speed
---DEPRECATED
function MOVE_TOWARDS_TABLE(position, towards_pos, speed) end

---MWWSE
---get vector moved towards b by x speed
---DEPRECATED
function MOVE_TOWARDS_VECTOR(position, towards_pos, speed) end

---MWWSE
---@param position any
---@param towards_pos any
---@param speed any
---@return table
---get table trated as vector moved towards b by x speed
function MOVE_TOWARDS_POINT_OR_VECTOR(position, towards_pos, speed) end

---MWWSE
---@param v Vector3
---@return Vector3
---returns a vector3 with the z value set to 0
function Vector3_flat(v) end

---MWWSE
---@param v Vector3
---@return Vector3
---DEPRECATED
function UA_yaw_radians(v) end

---MWWSE
---@param A any
---@param B any
---@param s any
---@return Vector3
---returns a vector3 that is moved towards another vector3 by a speed
function MOVE_TOWARDS_3D(A, B, s) end

---MWWSE
---@param position any
---@param towards_pos any
---@param speed any
---@return Vector3
---returns a vector3 that is moved away from another vector3 by a speed
function MOVE_AWAY_FROM_POINT(position, towards_pos, speed)  end

---MWWSE
---@param position any
---@param towards_pos any
---@param speed any
---@return Vector3
---returns a vector3 that is moved towards another vector3 by a speed
function MOVE_TOWARDS_POINT(position, towards_pos, speed) end

function MOVE_TOWARDS_VECTOR(point_a, point_b, speed) end

---MWWSE
---@param position Vector3|table
---@param input_angle radians
---@param speed distance
---@return Vector3
---returns a vector3 that is moved towards an angle by a speed
function MOVE_TOWARDS_ANGLE(position, towards_pos, input_angle, speed)  end

---MWWSE
---@param point_a any
---@param point_b any
---@param point_c any
---@return number
-- Calculate the angle between three points
function CALCULATE_ANGLE_BETWEEN_POINTS(point_a, point_b, point_c) end

---MWWSE
---@param unit_forward any
---@param wanted_forward any
---@return integer
---returns the forward facing angle between two vectors
function UA_forward_angle(unit_forward, wanted_forward) end

---MWWSE
---@param a any
---@param b any
---@return unknown
function UA_yaw_difference_radians(a, b) end

---MWWSE
---@param start_vector table|Vector2
---@param end_vector Vector3
---@param smoothing integer
---@return Vector3
---really shet way to smooth a vector
---calculates mid point between two points, and repeats
---EG smoothing 2 would be a 1/4 distance between start and end vector
---for the love of Vlad someone please implement sLerp
function SMOOTH_TABLE(start_vector, end_vector, smoothing) end

---MWWSE
---@param start_vector table_or_Vector2
---@param end_vector Vector3
---@param smoothing integer
---@return Vector3
---really shet way to smooth a vector
---calculates mid point between two points, and repeats
---EG smoothing 2 would be a 1/4 distance between start and end vector
---for the love of Vlad someone please implement sLerp
function SMOOTH_VECTOR(start_vector, end_vector, smoothing) end

---MWWSE
---@param v1 Vector3
---@param v2 Vector3
---@param blend_factor any
---@return Vector3
---DEPRECATED use Vector3.lerp() instead
function LERP(v1, v2, blend_factor) end

---MWWSE
---@param currentPosition any
---@param targetPosition any
---@param speed any
---@param dt any
---@return any
---returns a vector3 lerped towards a target position
---and multiplied by speed and dt
function SLERP_TOWARDS(currentPosition, targetPosition, speed, dt) end

---MWWSE
---@param currentPosition any
---@param targetPosition any
---@param speed any
---@param dt any
---@return unknown
---returns a vector3 lerped towards a target position
function SMOOTH_SLERP_TOWARDS(currentPosition, targetPosition, speed, dt) end

---MWWSE
---@param low any
---@param high any
---@param input any
---@return any
---returns a value clamped between two values high & low
function CLAMP_BETWEEN(low, high, input) end

---MWWSE
---@param vector any
---@param offset_position any
---@param size any
---@return boolean
---returns true if a vector is within a rectangle
function POINT_WITHIN_RECTANGLE(vector, offset_position, size) end

SE = SE or {}
SE.math_utilities = {}
SE.math_utilities.offset_point_towards_point = MOVE_TOWARDS_POINT_OR_VECTOR
SE.math_utilities.offset_point_away_from_point = MOVE_AWAY_FROM_POINT
SE.math_utilities.move_towards_angle = MOVE_TOWARDS_ANGLE
