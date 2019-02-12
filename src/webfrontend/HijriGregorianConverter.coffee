### CODE Copyright:  http://www.islamicity.com/PrayerTimes/defaultHijriConv.asp ###
class ez5.HijriGregorianConverter

	@gregorianToHijri: (value) ->
		return "" + ez5.HijriGregorianConverter::convert_text_to_dates('C', value)

	@hijriToGregorian: (value) ->
		return "" + ez5.HijriGregorianConverter::convert_text_to_dates('H', value)

	convert_text_to_dates: (format, txt) ->
		# convert dates
		txt = txt.trim()
		from = undefined
		to = undefined
		spl = undefined
		has_to = undefined
		to_date = undefined
		from_date = undefined
		if txt.length == 0
			return [
				null
				null
			]
		spl = txt.split(' - ')
		from = spl[0].trim()
		if spl.length > 1
			to = spl[1].trim()
			has_to = true
		
		from_date = @convert_text_to_date(format, from)
		if has_to
			to_date = @convert_text_to_date(format, to)
		if has_to
			from_date + ' - ' + to_date
		else
			from_date

	convert_text_to_date: (format, txt) ->
		spl = undefined
		year = undefined
		month = undefined
		day = undefined
		mode = undefined
		use_format = undefined
		
		if txt == null
			return null
		if txt.indexOf('.') > -1
			spl = txt.split('.')
			day = spl[0]
			month = spl[1]
			year = spl[2]
			mode = '.'
		else
		# this also covers the "year only case"
			spl = txt.split('-')
			year = spl[0]
			month = spl[1]
			day = spl[2]
			mode = '-'
		map = {}
		map[format + 'Day'] = parseInt(day) or 1
		map[format + 'Month'] = parseInt(month) or 1
		map[format + 'Year'] = parseInt(year)
		if format == 'C'
			@__gregToIsl map
		else
			@__islToGreg map
		if format == 'C'
			use_format = 'H'
		else
			use_format = 'C'

		if mode == '-'
			arr = [
				map[use_format + 'Year']
				map[use_format + 'Month']
				map[use_format + 'Day']
			]
		else
			arr = [
				map[use_format + 'Day']
				map[use_format + 'Month']
				map[use_format + 'Year']
			]

		year = "#{arr[0]}"
		if year.length < 4
			zeroArray = (0 for [1..4 - year.length])
			year = zeroArray.join("") + year
			arr[0] = year

		if spl.length == 1 # YEAR
			# mode is always "-"
			arr[0]
		else if spl.length == 2 # MONTH YEAR
			arr[0] + mode + arr[1]
		else
			arr.join mode

	__intPart: (floatNum) ->
		if floatNum < -0.0000001
			return Math.ceil(floatNum - 0.0000001)
		Math.floor floatNum + 0.0000001

	__isNumeric: (num) ->
		strlen = num.length
		i = undefined
		i = 0
		while i < strlen
	#if (!((num.charAt(i) >= '0') && (num.charAt(i)<='9') || (num.charAt(i)=='.')))
			if !(num.charAt(i) >= '0' and num.charAt(i) <= '9' or num.charAt(i) == '.' or num.charAt(i) == '-')
				return false
			++i
		return

	__gregToIsl: (arg) ->
		if @__gValidate(arg) == false
			return false
		d = parseInt(arg.CDay)
		m = parseInt(arg.CMonth)
		y = parseInt(arg.CYear)
		delta = 0
		if y > 1582 or y == 1582 and m > 10 or y == 1582 and m == 10 and d > 14
	#added delta=1 on jd to comply isna rulling 2007
			jd = @__intPart(1461 * (y + 4800 + @__intPart((m - 14) / 12)) / 4) + @__intPart(367 * (m - 2 - (12 * @__intPart((m - 14) / 12))) / 12) - @__intPart(3 * @__intPart((y + 4900 + @__intPart((m - 14) / 12)) / 100) / 4) + d - 32075 + delta
		else
	#added +1 on jd to comply isna rulling
			jd = 367 * y - @__intPart(7 * (y + 5001 + @__intPart((m - 9) / 7)) / 4) + @__intPart(275 * m / 9) + d + 1729777 + delta
		# arg.JD.value=jd
		#added -1 on jd1 to comply isna rulling
		jd1 = jd - delta
		# arg.wd.value=weekDay(jd1%7)
		l = jd - 1948440 + 10632
		n = @__intPart((l - 1) / 10631)
		l = l - (10631 * n) + 354
		j = @__intPart((10985 - l) / 5316) * @__intPart(50 * l / 17719) + @__intPart(l / 5670) * @__intPart(43 * l / 15238)
		l = l - (@__intPart((30 - j) / 15) * @__intPart(17719 * j / 50)) - (@__intPart(j / 16) * @__intPart(15238 * j / 43)) + 29
		m = @__intPart(24 * l / 709)
		d = l - @__intPart(709 * m / 24)
		y = 30 * n + j - 30
		arg.HDay = d
		arg.HMonth = m
		arg.HYear = y
		return

	__islToGreg: (arg) ->
		if @__hValidate(arg) == false
			return false
		d = parseInt(arg.HDay)
		m = parseInt(arg.HMonth)
		y = parseInt(arg.HYear)
		delta = 0
		#added - delta=1 on jd to comply isna rulling
		jd = @__intPart((11 * y + 3) / 30) + 354 * y + 30 * m - @__intPart((m - 1) / 2) + d + 1948440 - 385 - delta
		# arg.JD.value=jd
		# arg.wd.value=weekDay(jd%7)
		if jd > 2299160
			l = jd + 68569
			n = @__intPart(4 * l / 146097)
			l = l - @__intPart((146097 * n + 3) / 4)
			i = @__intPart(4000 * (l + 1) / 1461001)
			l = l - @__intPart(1461 * i / 4) + 31
			j = @__intPart(80 * l / 2447)
			d = l - @__intPart(2447 * j / 80)
			l = @__intPart(j / 11)
			m = j + 2 - (12 * l)
			y = 100 * (n - 49) + i + l
		else
			j = jd + 1402
			k = @__intPart((j - 1) / 1461)
			l = j - (1461 * k)
			n = @__intPart((l - 1) / 365) - @__intPart(l / 1461)
			i = l - (365 * n) + 30
			j = @__intPart(80 * i / 2447)
			d = i - @__intPart(2447 * j / 80)
			i = @__intPart(j / 11)
			m = j + 2 - (12 * i)
			y = 4 * k + n + i - 4716
		arg.CDay = d
		arg.CMonth = m
		arg.CYear = y
		return

	__hValidate: (arg) ->
		hdays = new Array(30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29)
		dh = undefined
		mh = undefined
		yh = undefined
		m1h = undefined
		leaph = undefined
		dh = arg.HDay
		mh = arg.HMonth
		yh = arg.HYear
		if arg.HYear == ''
			alert 'Hijri Year can not be empty'
			return false
		if @__isNumeric(yh) == false
			alert 'Hijri Year should be in numerics'
			return false
		m1h = yh % 30
		#the 2nd, 5th, 7th, 10th, 13th, 16th, 18th, 21st, 24th, 26th, and 29th years are leap years.
		leaph = if mh == 12 and (m1h == 2 or m1h == 5 or m1h == 7 or m1h == 10 or m1h == 13 or m1h == 16 or m1h == 18 or m1h == 21 or m1h == 24 or m1h == 26 or m1h == 29) then 1 else 0
		if dh > hdays[mh - 1] + leaph
			alert mh + '/' + dh + '/' + yh + ' is not a valid Hijri date.'
			return false
		true

	#adji added

	__gValidate: (arg) ->
		cdays = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
		yleap = undefined
		d = undefined
		m = undefined
		y = undefined
		m1 = undefined
		m2 = undefined
		m3 = undefined
		leap = undefined
		d = arg.CDay
		m = arg.CMonth
		y = arg.CYear
		if arg.CYear == ''
			alert 'Gregorian Year can be not empty'
			return false
		if @__isNumeric(y) == false
			alert 'Gregorian Year should be in numerics'
			return false
		m1 = y % 4
		m2 = y % 100
		m3 = y % 400
		leap = if m == 2 and (m3 == 0 or m1 == 0 and m2 != 0) then 1 else 0
		if d > cdays[m - 1] + leap
			alert m + '/' + d + '/' + y + ' is not a valid Gregorian date.'
			return false
		true