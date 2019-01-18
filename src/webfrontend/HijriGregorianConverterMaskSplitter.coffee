class ez5.HijriGregorianConverterMaskSplitter extends CustomMaskSplitter

	renderField: (opts) ->
		innerFields = @renderInnerFields(opts)

		fieldsRendererPlain = @__customFieldsRenderer.fields[0]
		if fieldsRendererPlain not instanceof FieldsRendererPlain
			return innerFields

		dateGregorian = fieldsRendererPlain.fields[0]
		dateHijri = fieldsRendererPlain.fields[1]
		if dateGregorian not instanceof DateColumn or dateHijri not instanceof DateColumn
			return innerFields

		if dateGregorian instanceof DateRangeColumn or dateHijri instanceof DateRangeColumn
			return innerFields

		data = opts.data

		toHijriButton = new LocaButton
			loca_key: "hijri.gregorian.converter.button.to-hijri"
			disabled: @__isDateInvalidOrEmpty(data, dateGregorian, opts)
			onClick: =>
				gregorianValue = @__getDateValue(data, dateGregorian)
				hijriValue = ez5.HijriGregorianConverter.gregorianToHijri(gregorianValue)
				dateHijri.updateValue(data, hijriValue)

		toGregorianButton = new LocaButton
			loca_key: "hijri.gregorian.converter.button.to-gregorian"
			disabled: @__isDateInvalidOrEmpty(data, dateHijri, opts)
			onClick: =>
				hijriValue = @__getDateValue(data, dateHijri)
				gregorianValue = ez5.HijriGregorianConverter.hijriToGregorian(hijriValue)
				dateGregorian.updateValue(data, gregorianValue)

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

	__getDateValue: (data, field) ->
		return data[field.name()]?.value

	getOptions: ->
		[]

	trashable: ->
		true

CUI.ready =>
	MaskSplitter.plugins.registerPlugin(ez5.HijriGregorianConverterMaskSplitter)