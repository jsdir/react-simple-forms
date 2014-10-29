_ = require "lodash"
React = require "react"
cx = require "react/lib/cx"
ReactCSSTransitionGroup = require "react/lib/ReactCSSTransitionGroup"

{div, input, select, option, i, button, textarea} = React.DOM

monthMap = _.map [
  "January"
  "February"
  "March"
  "April"
  "May"
  "June"
  "July"
  "August"
  "September"
  "October"
  "November"
  "December"
], (month, n) -> [n, month]

# Month starts with 1
daysInMonth = (month, year) -> new Date(year, month, 0).getDate()

Input =
  propTypes:
    options: React.PropTypes.object
    value: React.PropTypes.any
    onChange: React.PropTypes.func
    status: React.PropTypes.string
    onFocus: React.PropTypes.func
    onBlur: React.PropTypes.func
    focus: React.PropTypes.bool
    valid: React.PropTypes.object
    showIndicators: React.PropTypes.bool

  shouldRenderIndicator: ->
    if @props.showIndicators
      return @props.valid?.valid
    else
      return null

  shouldRenderFormatting: ->
    @props.valid?.valid is false and not @props.valid?.interactive

Text =
  onChange: (e) ->
    @props.onChange e.target.value

  componentDidMount: ->
    @focus()

  componentDidUpdate: ->
    @focus()

  focus: ->
    _.defer => @refs.input.getDOMNode().focus() if @props.focus

  renderIndicator: ->
    result = @shouldRenderIndicator()

    if result is true
      indicator = i className: "form-field-indicator fa fa-check"
    else if result is false
      indicator = i className: "form-field-indicator fa fa-times"
    else
      indicator = null

    return ReactCSSTransitionGroup transitionName: "fade", indicator

  renderInput: (el, options) ->
    props = _.extend
      ref: "input"
      value: @props.value
      onChange: @onChange
      className: cx "error": @shouldRenderFormatting()
      placeholder: @props.options.placeholder
    , options

    return div className: "form-field",
      @transferPropsTo el props
      @renderIndicator()

TextInput = React.createClass
  displayName: "TextInput"
  mixins: [Input, Text]

  render: ->
    @renderInput input

PasswordInput = React.createClass
  displayName: "PasswordInput"
  mixins: [Input, Text]

  render: ->
    @renderInput input, type: "password"

TextareaInput = React.createClass
  displayName: "TextareaInput"
  mixins: [Input, Text]

  render: ->
    @renderInput textarea

DateInput = React.createClass
  displayName: "DateInput"
  mixins: [Input]

  componentDidMount: ->
    @currentYear = (new Date()).getFullYear()

  getDate: ->
    new Date @props.value

  onMonthChange: (e) ->
    month = parseInt e.target.value
    date = @getDate()
    # Ensure that the day is valid with the selected month.
    # Correct the day if it is invalid.
    year = date.getFullYear()
    date.setDate Math.min date.getDate(), daysInMonth month + 1, year
    date.setMonth month
    @props.onChange date

  onDayChange: (e) ->
    date = @getDate()
    @props.value.setDate parseInt e.target.value
    @props.onChange @props.value

  onYearChange: (e) ->
    date = @getDate()
    date.setFullYear parseInt e.target.value
    @props.onChange date

  renderMonthSelector: ->
    months = _.map monthMap, (month) -> option
      value: month[0], key: month[0]
    , month[1]

    return select
      className: "input-date-month"
      value: @props.value.getMonth()
      onChange: @onMonthChange
    , months

  renderDaySelector: ->
    fullYear = @props.value.getFullYear()
    days = [1..daysInMonth(@props.value.getMonth() + 1, fullYear)]
    dayOptions = _.map days, (day) -> option value: day, key: day, day
    return select
      className: "input-date-day"
      value: @props.value.getDate()
      onChange: @onDayChange
    , dayOptions

  renderYearSelector: ->
    years = _.map [@currentYear..1900], (year) ->
      option value: year, key: year, year
    return select
      className: "input-date-year"
      value: @props.value.getFullYear()
      onChange: @onYearChange
    , years

  render: ->
    div className: "group input-date",
      @renderMonthSelector()
      @renderDaySelector()
      @renderYearSelector()

ChoiceInput = React.createClass
  displayName: "ChoiceInput"
  mixins: [Input]

  propTypes:
    choices: React.PropTypes.object.isRequired
    btnClass: React.PropTypes.string

  onChoiceSelect: (value) ->
    @setState {value}
    @props.onChange value

  render: ->
    btnClass = @props.btnClass or ""
    div className: "group", _.map @props.choices, (title, choice) =>
      button
        key: choice
        onClick: => @onChoiceSelect choice
        className: btnClass + " " + cx active: @props.value is choice
      , title

module.exports = {
  TextInput
  PasswordInput
  DateInput
  ChoiceInput
  TextareaInput
}
