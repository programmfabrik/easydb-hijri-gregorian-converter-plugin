class ez5.HijriGregorianConverterMaskSplitter extends CustomMaskSplitter

	renderField: (opts) ->
		innerFields = @renderInnerFields(opts)

		if opts.mode == "detail"
			return innerFields

		fieldsRendererPlain = @__customFieldsRenderer.fields[0]
		if fieldsRendererPlain not instanceof FieldsRendererPlain
			return innerFields

		fields = fieldsRendererPlain.getFields() or []
		if not fields
			return innerFields

		dateFields = fields.filter((field) ->
			return field instanceof DateColumn
		)

		dateGregorian = dateFields[0]
		dateHijri = dateFields[1]

		if not dateGregorian or not dateHijri
			return innerFields

		# Both DateColumns or both DateRangeColumn.
		if dateGregorian instanceof DateRangeColumn and dateHijri not instanceof DateRangeColumn
			return innerFields

		if dateHijri instanceof DateRangeColumn and dateGregorian not instanceof DateRangeColumn
			return innerFields

		data = opts.data

		toHijriButton = new LocaButton
			loca_key: "hijri.gregorian.converter.button.to-hijri"
			disabled: @__isDateInvalidOrEmpty(data, dateGregorian, opts)
			onClick: =>
				gregorianValue = @__getDateValue(data, dateGregorian)
				hijriValue = @__toHijri(gregorianValue)
				dateHijri.updateValue(data, hijriValue)
				toHijriButton.disable()
				toGregorianButton.disable()

		toGregorianButton = new LocaButton
			loca_key: "hijri.gregorian.converter.button.to-gregorian"
			disabled: @__isDateInvalidOrEmpty(data, dateHijri, opts)
			onClick: =>
				hijriValue = @__getDateValue(data, dateHijri)
				gregorianValue = @__toGregorian(hijriValue)
				dateGregorian.updateValue(data, gregorianValue)
				toHijriButton.disable()
				toGregorianButton.disable()

		areDatesAlreadyConverted = =>
			if toHijriButton.isDisabled() or toGregorianButton.isDisabled()
				return

			gregorianValue = @__getDateValue(data, dateGregorian)
			hijriValue = @__getDateValue(data, dateHijri)
			hijriConvertedValue = @__toGregorian(hijriValue)
			if @__isSameDateValue(dateGregorian, gregorianValue, hijriConvertedValue)
				toHijriButton.disable()
				toGregorianButton.disable()
			return
		areDatesAlreadyConverted()

		CUI.Events.listen
			node: innerFields[0]
			type: "editor-changed"
			call: =>
				if @__isDateInvalidOrEmpty(data, dateGregorian, opts)
					toHijriButton.disable()
				else
					toHijriButton.enable()

				if @__isDateInvalidOrEmpty(data, dateHijri, opts)
					toGregorianButton.disable()
				else
					toGregorianButton.enable()

				areDatesAlreadyConverted()

		buttonBar = new CUI.Buttonbar(class: "ez5-field-block", buttons: [toHijriButton, toGregorianButton])

		CUI.dom.append(innerFields[0], buttonBar)
		return innerFields

	__isDateInvalidOrEmpty: (data, field, opts) ->
		gregorianValue = @__getDateValue(data, field)
		if CUI.util.isEmpty(gregorianValue)
			return true

		checkedValue = field.checkValue(data, null, opts)
		if not CUI.util.isTrue(checkedValue) # If checkedValue is true it means that the value is valid.
			return true

		return false

	__getDateValue: (_data, field) ->
		data = _data[field.name()]
		if not data
			return

		if not CUI.util.isUndef(data.value) # Date Field
			return data.value

		return from: data.from, to: data.to # Date Range field

	__toGregorian: (value) ->
		if CUI.util.isPlainObject(value) # Date Range column
			returnValue = {}
			if value.from
				returnValue.from = ez5.HijriGregorianConverter.hijriToGregorian(value.from)
			if value.to
				returnValue.to = ez5.HijriGregorianConverter.hijriToGregorian(value.to)
			return returnValue
		return ez5.HijriGregorianConverter.hijriToGregorian(value)

	__toHijri: (value) ->
		if CUI.util.isPlainObject(value) # Date Range column
			returnValue = {}
			if value.from
				returnValue.from = ez5.HijriGregorianConverter.gregorianToHijri(value.from)
			if value.to
				returnValue.to = ez5.HijriGregorianConverter.gregorianToHijri(value.to)
			return returnValue
		return ez5.HijriGregorianConverter.gregorianToHijri(value)

	__isSameDateValue: (dateField, value, convertedValue) ->
		if CUI.util.isPlainObject(value) and CUI.util.isPlainObject(convertedValue) # Date Range column
			return dateField.renderDateValue("#{value.from}") == dateField.renderDateValue("#{convertedValue.to}") &&
				dateField.renderDateValue("#{value.from}") == dateField.renderDateValue("#{convertedValue.to}")

		return dateField.renderDateValue("#{value}") == dateField.renderDateValue("#{convertedValue}")

	getOptions: ->
		[]

	trashable: ->
		true

	isEnabledForNested: ->
		return true

CUI.ready =>
	MaskSplitter.plugins.registerPlugin(ez5.HijriGregorianConverterMaskSplitter)