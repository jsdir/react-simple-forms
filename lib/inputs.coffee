_ = require "lodash"
React = require "react"
cx = require "react/lib/cx"
ReactCSSTransitionGroup = require "react/lib/ReactCSSTransitionGroup"

{div, input, select, option, i} = React.DOM

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
    focus: React.PropTypes.bool
    # onBlur: React.PropTypes.func

Text =
  onChange: (e) ->
    @props.onChange e.target.value

  componentDidMount: ->
    @focus()

  componentDidUpdate: ->
    @focus()

  focus: ->
    _.defer =>
      @refs.input.getDOMNode().focus() if @props.focus

  renderIndicator: ->
    className = null

    if @props.fieldState is "invalidInteractive"
      iconClass = "fa-times"
    else if @props.fieldState is "valid"
      iconClass = "fa-check"

    indicator = null
    if iconClass
      indicator = i className: "form-field-indicator fa #{iconClass}"

    return ReactCSSTransitionGroup transitionName: "fade", indicator

TextInput = React.createClass
  displayName: "TextInput"
  mixins: [Input, Text]

  render: ->
    div className: "form-field",
      @transferPropsTo input
        ref: "input"
        value: @props.value
        onChange: @onChange
        className: cx "error": @props.status is "invalid"
        placeholder: @props.options.placeholder
      @renderIndicator()

PasswordInput = React.createClass
  displayName: "PasswordInput"
  mixins: [Input, Text]

  render: ->
    div className: "form-field", ref: "input",
      @transferPropsTo input
        ref: "input"
        type: "password"
        onChange: @onChange
        className: cx "error": @props.fieldState is "invalid"
        placeholder: @props.options.placeholder
      @renderIndicator()

DateInput = React.createClass
  displayName: "DateInput"
  mixins: [Input]

  getInitialState: ->
    date = new Date()
    return {
      date
      currentYear: date.getFullYear()
    }

  onMonthChange: (month) ->
    date = @state.date
    # Ensure that the day is valid with the selected month.
    # Correct the day if it is invalid.
    year = @state.date.getFullYear()
    date.setDate Math.min date.getDate(), daysInMonth month, year
    date.setMonth month
    @setDate date

  onDayChange: (day) ->
    date = @state.date
    date.setDate day
    @setDate date

  onYearChange: (year) ->
    date = @state.date
    date.setFullYear year
    @setDate date

  setDate: (date) ->
    @setState {date}
    @onChange date

  renderMonthSelector: ->
    months = _.map monthMap, (month) -> option value: month[0], month[1]
    return select
      value: @state.date.getMonth()
      onChange: @onMonthChange
    , months

  renderDaySelector: ->
    days = [1..daysInMonth(@state.date.getMonth(), @state.date.getFullYear())]
    dayOptions = _.map days, (day) -> option value: day, day
    return select
      value: @state.date.getDate()
      onChange: @onDayChange
    , dayOptions

  renderYearSelector: ->
    years = _.map [@state.currentYear..1900], (year) ->
      option value: year, year
    return select
      value: @state.date.getFullYear()
      onChange: @onYearChange
    , years

  render: ->
    div null,
      @renderMonthSelector()
      @renderDaySelector()
      @renderYearSelector()

ChoiceInput = React.createClass
  displayName: "ChoiceInput"
  mixins: [Input]

  propTypes:
    choices: React.PropTypes.array.isRequired
    default: React.PropTypes.string

  getInitialState: ->
    value: null

  onChoiceSelect: (value) ->
    @setState {value}
    @props.onChange value

  render: ->
    div className: "btn-group", _.map @props.choices, (choice) =>
      button
        onClick: => @onChoiceSelect choice
        className: "active" if @state.choice is choice
      , @props.choices[choice]

module.exports = {
  TextInput
  PasswordInput
  DateInput
  ChoiceInput
}
