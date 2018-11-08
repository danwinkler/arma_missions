// Grabs all markers starting with a _prefix
// Example call:
// _markers = "marker_prefix_" call get_markers_with_prefix;
get_markers_with_prefix = {
	_prefix = _this;
	_prefix_length = count _prefix;
	_filteredMarkers = [];

	{
		_resized = toArray _x;
		if(count _resized >= _prefix_length) then {
			_resized resize _prefix_length;
			if(toString _resized == _prefix) then {
				_filteredMarkers = _filteredMarkers + [_x];
			};
		};
	} foreach allMapMarkers;

	_filteredMarkers;
};