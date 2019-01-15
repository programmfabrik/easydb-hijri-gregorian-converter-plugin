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

		data = opts.data
		buttonBar = new CUI.Buttonbar(class: "ez5-field-block", buttons: [
			loca_key: "hijri.gregorian.converter.button.to-hijri"
			onClick: =>
				gregorianValue = dateGregorian.getRenderedValue(data)
				if CUI.util.isEmpty(gregorianValue) or not CUI.util.isString(gregorianValue)
					return

				hijriValue = ez5.HijriGregorianConverter.gregorianToHijri(gregorianValue)
				dateHijri.updateRenderedValue(data, hijriValue)
		,
			loca_key: "hijri.gregorian.converter.button.to-gregorian"
			onClick: =>
				hijriValue = dateHijri.getRenderedValue(data)
				if CUI.util.isEmpty(hijriValue) or not CUI.util.isString(hijriValue)
					return

				gregorianValue = ez5.HijriGregorianConverter.hijriToGregorian(hijriValue)
				dateGregorian.updateRenderedValue(data, gregorianValue)
		])

		CUI.dom.append(innerFields[0], buttonBar)
		return innerFields

	getOptions: ->
		[]

	trashable: ->
		true

CUI.ready =>
	MaskSplitter.plugins.registerPlugin(ez5.HijriGregorianConverterMaskSplitter)