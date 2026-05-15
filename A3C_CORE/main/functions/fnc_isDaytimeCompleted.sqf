// A3C_main_fnc_isDaytimeCompleted

params ["_targetYear", "_targetMonth", "_targetDay", "_targetHour", "_targetMin"];

date params ["_currentYear", "_currentMonth", "_currentDay", "_currentHour", "_currentMin"];

private _isLaterYear = _currentYear > _targetYear;
private _isSameYear = _currentYear == _targetYear;

private _isLaterMonth = _currentMonth > _targetMonth;
private _isSameMonth = _currentMonth == _targetMonth;

private _isLaterDay = _currentDay > _targetDay;
private _isSameDay = _currentDay == _targetDay;

private _isLaterHour = _currentHour > _targetHour;
private _isSameHour = _currentHour == _targetHour;

private _isSameOrLaterMinute = _currentMin >= _targetMin;

_isLaterYear || {
	_isSameYear && {
		_isLaterMonth || {
			_isSameMonth && {
				_isLaterDay || {
					_isSameDay && {
						_isLaterHour || {
							_isSameHour && {
								_isSameOrLaterMinute
							}
						}
					}
				}
			}
		}
	}
}