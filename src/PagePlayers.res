/*
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
open Belt
open Data
open Router
module Id = Data.Id

let sortFirstName = Hooks.GetString((x: Player.t) => x.firstName)
let sortLastName = Hooks.GetString((x: Player.t) => x.lastName)
let sortRating = Hooks.GetInt((x: Player.t) => x.rating)
let sortMatchCount = Hooks.GetInt((x: Player.t) => Player.NatInt.toInt(x.matchCount))

/**
 * This module is a heavily-modified version of code that was generated by the
 * re-formality PPX. Much of the original code has been removed or edited, but
 * the basic outline and the types are mostly the same.
 *
 * It probably needs to be replaced by something better.
 */
module Form = {
  module FormHelper = Utils.FormHelper

  module Input = {
    type t = {firstName: string, lastName: string, rating: string, matchCount: string}
    let initial = {firstName: "", lastName: "", rating: "1200", matchCount: "0"}
  }

  module Output = {
    type t = {firstName: string, lastName: string, rating: int, matchCount: Player.NatInt.t}
  }

  module Validate = {
    let firstName = firstName =>
      switch firstName {
      | "" => Error("First name is required")
      | name => Ok(name)
      }
    let lastName = lastName =>
      switch lastName {
      | "" => Error("Last name is required")
      | name => Ok(name)
      }
    let rating = rating =>
      switch Int.fromString(rating) {
      | None => Error("Rating must be a number")
      | Some(rating) => Ok(rating)
      }
    let matchCount = matchCount =>
      switch Int.fromString(matchCount) {
      | None => Error("Match count must be a number")
      | Some(i) => Ok(Player.NatInt.fromInt(i))
      }
  }

  module FieldStatuses = {
    type t = {
      matchCount: FormHelper.fieldStatus<Player.NatInt.t>,
      rating: FormHelper.fieldStatus<int>,
      lastName: FormHelper.fieldStatus<string>,
      firstName: FormHelper.fieldStatus<string>,
    }
    let initial = {matchCount: Pristine, rating: Pristine, lastName: Pristine, firstName: Pristine}
  }

  type action =
    | UpdateMatchCountField(string)
    | UpdateRatingField(string)
    | UpdateLastNameField(string)
    | UpdateFirstNameField(string)
    | BlurMatchCountField
    | BlurRatingField
    | BlurLastNameField
    | BlurFirstNameField
    | Submit(Output.t => unit)
    | Reset

  let initialState = input => {
    FormHelper.input,
    fieldStatuses: FieldStatuses.initial,
    formStatus: Editing,
  }

  let validateForm = ({FormHelper.input: input, fieldStatuses, _}) => {
    let matchCountResult = switch fieldStatuses.FieldStatuses.matchCount {
    | Pristine => Validate.matchCount(input.Input.matchCount)
    | Dirty(result) => result
    }
    let ratingResult = switch fieldStatuses.rating {
    | Pristine => Validate.rating(input.rating)
    | Dirty(result) => result
    }
    let lastNameResult = switch fieldStatuses.lastName {
    | Pristine => Validate.lastName(input.lastName)
    | Dirty(result) => result
    }
    let firstNameResult = switch fieldStatuses.firstName {
    | Pristine => Validate.firstName(input.firstName)
    | Dirty(result) => result
    }
    switch (matchCountResult, ratingResult, lastNameResult, firstNameResult) {
    | (Ok(matchCount), Ok(rating), Ok(lastName), Ok(firstName)) =>
      FormHelper.Valid({
        output: {Output.matchCount, rating, lastName, firstName},
        fieldStatuses: {
          FieldStatuses.matchCount: Dirty(matchCountResult),
          rating: Dirty(ratingResult),
          lastName: Dirty(lastNameResult),
          firstName: Dirty(firstNameResult),
        },
      })
    | (Ok(_) | Error(_), Ok(_) | Error(_), Ok(_) | Error(_), Ok(_) | Error(_)) =>
      Invalid({
        fieldStatuses: {
          matchCount: Dirty(matchCountResult),
          rating: Dirty(ratingResult),
          lastName: Dirty(lastNameResult),
          firstName: Dirty(firstNameResult),
        },
      })
    }
  }

  type t = {state: FormHelper.state<Input.t, Output.t, FieldStatuses.t>, dispatch: action => unit}

  let useForm = initialInput => {
    let memoizedInitialState = React.useMemo1(() => initialState(initialInput), [initialInput])
    let (state, dispatch) = React.useReducer((state, action) =>
      switch action {
      | UpdateMatchCountField(nextValue) => {
          ...state,
          FormHelper.input: {...state.FormHelper.input, Input.matchCount: nextValue},
          fieldStatuses: {
            ...state.fieldStatuses,
            FieldStatuses.matchCount: Dirty(Validate.matchCount(nextValue)),
          },
        }
      | UpdateRatingField(nextValue) => {
          ...state,
          input: {...state.input, rating: nextValue},
          fieldStatuses: {...state.fieldStatuses, rating: Dirty(Validate.rating(nextValue))},
        }
      | UpdateLastNameField(nextValue) => {
          ...state,
          input: {...state.input, lastName: nextValue},
          fieldStatuses: {
            ...state.fieldStatuses,
            lastName: Dirty(Validate.lastName(nextValue)),
          },
        }
      | UpdateFirstNameField(nextValue) => {
          ...state,
          input: {...state.input, firstName: nextValue},
          fieldStatuses: {
            ...state.fieldStatuses,
            firstName: Dirty(Validate.firstName(nextValue)),
          },
        }
      | BlurMatchCountField =>
        let result = FormHelper.validateFieldOnBlurWithValidator(
          ~input=state.input.matchCount,
          ~fieldStatus=state.fieldStatuses.matchCount,
          ~validator=Validate.matchCount,
        )
        switch result {
        | Some(matchCount) => {...state, fieldStatuses: {...state.fieldStatuses, matchCount}}
        | None => state
        }
      | BlurRatingField =>
        let result = FormHelper.validateFieldOnBlurWithValidator(
          ~input=state.input.rating,
          ~fieldStatus=state.fieldStatuses.rating,
          ~validator=Validate.rating,
        )
        switch result {
        | Some(rating) => {...state, fieldStatuses: {...state.fieldStatuses, rating}}
        | None => state
        }
      | BlurLastNameField =>
        let result = FormHelper.validateFieldOnBlurWithValidator(
          ~input=state.input.lastName,
          ~fieldStatus=state.fieldStatuses.lastName,
          ~validator=Validate.lastName,
        )
        switch result {
        | Some(lastName) => {...state, fieldStatuses: {...state.fieldStatuses, lastName}}
        | None => state
        }
      | BlurFirstNameField =>
        let result = FormHelper.validateFieldOnBlurWithValidator(
          ~input=state.input.firstName,
          ~fieldStatus=state.fieldStatuses.firstName,
          ~validator=Validate.firstName,
        )
        switch result {
        | Some(firstName) => {...state, fieldStatuses: {...state.fieldStatuses, firstName}}
        | None => state
        }
      | Submit(onSubmit) =>
        switch state.formStatus {
        | Submitting(_) => state
        | Editing =>
          switch validateForm(state) {
          | Valid({output, fieldStatuses}) => {
              ...state,
              fieldStatuses,
              formStatus: Submitting(output, onSubmit),
            }
          | Invalid({fieldStatuses}) => {...state, fieldStatuses, formStatus: Editing}
          }
        }
      | Reset => initialState(initialInput)
      }
    , memoizedInitialState)
    React.useEffect1(() => {
      switch state.formStatus {
      | Submitting(output, onSubmit) =>
        onSubmit(output)
        dispatch(Reset)
      | Editing => ()
      }
      None
    }, [state.formStatus])

    {state, dispatch}
  }
  let updateMatchCount = ({dispatch, _}, nextValue) => UpdateMatchCountField(nextValue)->dispatch
  let updateRating = ({dispatch, _}, nextValue) => UpdateRatingField(nextValue)->dispatch
  let updateLastName = ({dispatch, _}, nextValue) => UpdateLastNameField(nextValue)->dispatch
  let updateFirstName = ({dispatch, _}, nextValue) => UpdateFirstNameField(nextValue)->dispatch
  let blurMatchCount = ({dispatch, _}) => BlurMatchCountField->dispatch
  let blurRating = ({dispatch, _}) => BlurRatingField->dispatch
  let blurLastName = ({dispatch, _}) => BlurLastNameField->dispatch
  let blurFirstName = ({dispatch, _}) => BlurFirstNameField->dispatch
  let matchCountResult = ({state, _}) =>
    FormHelper.exposeFieldResult(state.fieldStatuses.matchCount)
  let ratingResult = ({state, _}) => FormHelper.exposeFieldResult(state.fieldStatuses.rating)
  let lastNameResult = ({state, _}) => FormHelper.exposeFieldResult(state.fieldStatuses.lastName)
  let firstNameResult = ({state, _}) => FormHelper.exposeFieldResult(state.fieldStatuses.firstName)
  let input = ({state, _}) => state.input
  let dirty = ({state, _}) =>
    switch state.fieldStatuses {
    | {matchCount: Pristine, rating: Pristine, lastName: Pristine, firstName: Pristine} => false
    | {
        matchCount: Pristine | Dirty(_),
        rating: Pristine | Dirty(_),
        lastName: Pristine | Dirty(_),
        firstName: Pristine | Dirty(_),
      } => true
    }
  let valid = ({state, _}) =>
    switch validateForm(state) {
    | Valid(_) => true
    | Invalid(_) => false
    }
  let submitting = ({state, _}) =>
    switch state.formStatus {
    | Submitting(_) => true
    | Editing => false
    }
  let submit = ({dispatch, _}, fn) => Submit(fn)->dispatch
}

let errorNotification = x =>
  switch x {
  | Some(Error(e)) => <Utils.Notification kind=Error> {e->React.string} </Utils.Notification>
  | Some(Ok(_)) | None => React.null
  }

module NewPlayerForm = {
  @react.component
  let make = (~dispatch, ~addPlayerCallback=?) => {
    let form = Form.useForm(Form.Input.initial)
    let input = Form.input(form)
    <form
      onSubmit={event => {
        ReactEvent.Form.preventDefault(event)
        Form.submit(form, ({firstName, lastName, rating, matchCount}) => {
          let id = Data.Id.random()
          dispatch(Db.Set(id, {Player.firstName, lastName, rating, id, type_: Person, matchCount}))
          switch addPlayerCallback {
          | None => ()
          | Some(fn) => fn(id)
          }
        })
      }}>
      <fieldset>
        <legend> {React.string("Register a new player")} </legend>
        <p>
          <label htmlFor="firstName"> {React.string("First name")} </label>
          <input
            name="firstName"
            type_="text"
            onBlur={_ => Form.blurFirstName(form)}
            value=input.firstName
            required=true
            onChange={event => Form.updateFirstName(form, (event->ReactEvent.Form.target)["value"])}
          />
        </p>
        {errorNotification(Form.firstNameResult(form))}
        <p>
          <label htmlFor="lastName"> {React.string("Last name")} </label>
          <input
            name="lastName"
            type_="text"
            value=input.lastName
            onBlur={_ => Form.blurLastName(form)}
            required=true
            onChange={event => Form.updateLastName(form, (event->ReactEvent.Form.target)["value"])}
          />
        </p>
        {errorNotification(Form.lastNameResult(form))}
        <p>
          <label htmlFor="form-newplayer-rating"> {React.string("Rating")} </label>
          <input
            name="rating"
            id="form-newplayer-rating"
            type_="number"
            value=input.rating
            onBlur={_ => Form.blurRating(form)}
            required=true
            onChange={event => Form.updateRating(form, (event->ReactEvent.Form.target)["value"])}
          />
        </p>
        {errorNotification(Form.ratingResult(form))}
        <p>
          <button disabled={Form.submitting(form) || !Form.valid(form)}>
            {"Add"->React.string}
          </button>
        </p>
      </fieldset>
    </form>
  }
}

module PlayerList = {
  @react.component
  let make = (
    ~sorted,
    ~sortDispatch,
    ~players: Id.Map.t<Data.Player.t>,
    ~playersDispatch,
    ~configDispatch,
    ~windowDispatch=_ => (),
  ) => {
    let dialog = Hooks.useBool(false)
    React.useEffect1(() => {
      windowDispatch(Window.SetTitle("Players"))
      Some(() => windowDispatch(SetTitle("")))
    }, [windowDispatch])
    let delPlayer = (event, id) => {
      ReactEvent.Mouse.preventDefault(event)
      let playerOpt = Map.get(players, id)
      switch playerOpt {
      | None => ()
      | Some(player) =>
        let message = `Are you sure you want to delete ${Player.fullName(player)}?`
        if Webapi.Dom.Window.confirm(Webapi.Dom.window, message) {
          playersDispatch(Db.Del(id))
          configDispatch(Db.DelAvoidSingle(id))
        }
      }
    }
    <div className="content-area">
      <div className="toolbar toolbar__left">
        <button onClick={_ => dialog.setTrue()}>
          <Icons.UserPlus />
          {React.string(" Add a new player")}
        </button>
      </div>
      <table style={ReactDOM.Style.make(~margin="auto", ())}>
        <caption> {React.string("Player roster")} </caption>
        <thead>
          <tr>
            <th>
              <Hooks.SortButton data=sorted dispatch=sortDispatch sortColumn=sortFirstName>
                {React.string("First name")}
              </Hooks.SortButton>
            </th>
            <th>
              <Hooks.SortButton data=sorted dispatch=sortDispatch sortColumn=sortLastName>
                {React.string("Last name")}
              </Hooks.SortButton>
            </th>
            <th>
              <Hooks.SortButton data=sorted dispatch=sortDispatch sortColumn=sortRating>
                {React.string("Rating")}
              </Hooks.SortButton>
            </th>
            <th>
              <Hooks.SortButton data=sorted dispatch=sortDispatch sortColumn=sortMatchCount>
                {React.string("Matches")}
              </Hooks.SortButton>
            </th>
            <th>
              <Externals.VisuallyHidden> {React.string("Controls")} </Externals.VisuallyHidden>
            </th>
          </tr>
        </thead>
        <tbody className="content">
          {Array.map(sorted.table, p =>
            <tr key={p.id->Data.Id.toString}>
              <td className="table__player" colSpan=2>
                <Link to_=Player(p.id)> {p->Player.fullName->React.string} </Link>
              </td>
              <td className="table__number"> {p.rating->React.int} </td>
              <td className="table__number"> {p.matchCount->Player.NatInt.toInt->React.int} </td>
              <td>
                <button className="danger button-ghost" onClick={event => delPlayer(event, p.id)}>
                  <Icons.Trash />
                  <Externals.VisuallyHidden>
                    {React.string(`Delete ${Player.fullName(p)}`)}
                  </Externals.VisuallyHidden>
                </button>
              </td>
            </tr>
          )->React.array}
        </tbody>
      </table>
      <Externals.Dialog
        isOpen=dialog.state
        onDismiss={_ => dialog.setFalse()}
        ariaLabel="New player form"
        className="">
        <button className="button-micro" onClick={_ => dialog.setFalse()}>
          {React.string("Close")}
        </button>
        <NewPlayerForm dispatch=playersDispatch />
      </Externals.Dialog>
    </div>
  }
}

module PlayerStats = {
  type t = {wins: int, losses: int, draws: int}

  let succWins = t => {...t, wins: succ(t.wins)}

  let succLosses = t => {...t, losses: succ(t.losses)}

  let succDraws = t => {...t, draws: succ(t.draws)}

  let empty = {wins: 0, losses: 0, draws: 0}

  let percent = (a, b) => {
    let x = switch b {
    | 0 => 0.0
    | b => Float.fromInt(a) /. Float.fromInt(b)
    }
    x->Numeral.make->Numeral.format("%")
  }

  @react.component
  let make = (~playerId) => {
    let {items, _} = Db.useAllTournaments()
    let idEqual = Data.Id.eq(playerId, ...)
    let {wins, losses, draws} = Map.reduce(items, empty, (acc, _id, tournament) =>
      tournament.roundList
      ->Data.Rounds.toArray
      ->Array.reduce(acc, (acc, round) =>
        Data.Rounds.Round.toArray(round)->Array.reduce(
          acc,
          (acc, match) =>
            switch (match.result, idEqual(match.blackId), idEqual(match.whiteId)) {
            | (BlackWon | WhiteAborted, true, _)
            | (WhiteWon | BlackAborted, _, true) =>
              succWins(acc)
            | (BlackWon | WhiteAborted, _, true)
            | (WhiteWon | BlackAborted, true, _) =>
              succLosses(acc)
            | (Draw, _, true) | (Draw, true, _) => succDraws(acc)
            | (BlackWon | WhiteWon | Draw | BlackAborted | WhiteAborted, false, false)
            | (Aborted | NotSet, _, _) => acc
            },
        )
      )
    )
    let total = wins + losses + draws
    <div>
      <table style={ReactDOM.Style.make(~margin="0", ())}>
        <thead>
          <tr>
            <th> {"Stat"->React.string} </th>
            <th> {"Count"->React.string} </th>
            <th> {"Ratio"->React.string} </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <th scope="row"> {"Won"->React.string} </th>
            <td className="table__number"> {wins->React.int} </td>
            <td className="table__number"> {percent(wins, total)->React.string} </td>
          </tr>
          <tr>
            <th scope="row"> {"Lost"->React.string} </th>
            <td className="table__number"> {losses->React.int} </td>
            <td className="table__number"> {percent(losses, total)->React.string} </td>
          </tr>
          <tr>
            <th scope="row"> {"Drew"->React.string} </th>
            <td className="table__number"> {draws->React.int} </td>
            <td className="table__number"> {percent(draws, total)->React.string} </td>
          </tr>
        </tbody>
      </table>
      <p className="caption-20">
        {`These statistics are generated from current tournament data. Their total may differ from
          the "matches played" number above.`->React.string}
      </p>
    </div>
  }
}

module AvoidForm = {
  @react.component
  let make = (~playerId, ~players, ~config: Data.Config.t, ~configDispatch) => {
    let avoidMap = Id.Pair.Set.toMap(config.avoidPairs)
    let singAvoidList = Map.getWithDefault(avoidMap, playerId, Set.make(~id=Id.id))
    let unavoided =
      players
      ->Map.keysToArray
      ->Array.keep(id => !Set.has(singAvoidList, id) && !Id.eq(id, playerId))
      ->Array.map(Player.getMaybe(players, ...))
      ->SortArray.stableSortBy(Data.Player.compareName)
    let (selectedAvoider, setSelectedAvoider) = React.useState(() => None)
    // Reset the selctedAvoider to the first on the list if it's None and the list is nonempty.
    // Better to just shadow the value instead of setting the state again.
    let selectedAvoider = switch selectedAvoider {
    | None => unavoided[0]
    | Some(_) as x => x
    }
    let avoidAdd = event => {
      ReactEvent.Form.preventDefault(event)
      switch selectedAvoider {
      | None => ()
      | Some(selectedAvoider) =>
        switch Id.Pair.make(playerId, selectedAvoider.id) {
        | None => ()
        | Some(pair) =>
          configDispatch(Db.AddAvoidPair(pair))
          setSelectedAvoider(_ => None)
        }
      }
    }
    let handleAvoidChange = event => {
      let id: Data.Id.t = ReactEvent.Form.currentTarget(event)["value"]
      setSelectedAvoider(_ => Map.get(players, id))
    }
    let handleAvoidBlur = event => {
      let id: Data.Id.t = ReactEvent.Focus.currentTarget(event)["value"]
      setSelectedAvoider(_ => Map.get(players, id))
    }
    <>
      {if Set.isEmpty(singAvoidList) {
        <p> {React.string("None")} </p>
      } else {
        <ul>
          {singAvoidList
          ->Set.toArray
          ->Array.map(Player.getMaybe(players, ...))
          ->SortArray.stableSortBy(Player.compareName)
          ->Array.map(p => {
            let fullName = Player.fullName(p)
            <li key={p.id->Data.Id.toString}>
              {fullName->React.string}
              <button
                ariaLabel={`Remove ${fullName} from avoid list.`}
                title={`Remove ${fullName} from avoid list.`}
                className="danger button-ghost"
                onClick={_ =>
                  switch Id.Pair.make(playerId, p.id) {
                  | None => ()
                  | Some(pair) => configDispatch(Db.DelAvoidPair(pair))
                  }}>
                <Icons.Trash />
              </button>
            </li>
          })
          ->React.array}
        </ul>
      }}
      <form onSubmit=avoidAdd>
        <label htmlFor="avoid-select"> {React.string("Select a new player to avoid.")} </label>
        {switch selectedAvoider {
        | Some(selectedAvoider) =>
          <>
            <select
              id="avoid-select"
              onBlur=handleAvoidBlur
              onChange=handleAvoidChange
              value={selectedAvoider.id->Data.Id.toString}>
              {unavoided
              ->Array.map(p => {
                let id = Data.Id.toString(p.id)
                <option key=id value=id> {p->Player.fullName->React.string} </option>
              })
              ->React.array}
            </select>
            {React.string(" ")}
            <input className="button-micro" type_="submit" value="Add" />
          </>
        | None => React.string("No players are available to avoid.")
        }}
      </form>
    </>
  }
}

module Profile = {
  @react.component
  let make = (
    ~player: Player.t,
    ~players,
    ~playersDispatch,
    ~config: Data.Config.t,
    ~configDispatch,
    ~windowDispatch=_ => (),
  ) => {
    let {id: playerId, firstName, lastName, rating, matchCount: initialMatchCount, type_} = player
    let form = Form.useForm({
      firstName,
      lastName,
      rating: Int.toString(rating),
      matchCount: Player.NatInt.toString(initialMatchCount),
    })
    let input = Form.input(form)
    let playerName = input.firstName ++ " " ++ input.lastName
    React.useEffect2(() => {
      windowDispatch(Window.SetTitle("Profile for " ++ playerName))
      Some(() => windowDispatch(SetTitle("")))
    }, (windowDispatch, playerName))
    <div className="content-area">
      <Link
        to_=PlayerList
        onClick={event =>
          if Form.dirty(form) && !Webapi.Dom.Window.confirm(Webapi.Dom.window, "Discard changes?") {
            ReactEvent.Mouse.preventDefault(event)
          }}>
        <Icons.ChevronLeft />
        {React.string(" Back")}
      </Link>
      <h2> {React.string("Profile for " ++ playerName)} </h2>
      <form
        onSubmit={event => {
          ReactEvent.Form.preventDefault(event)
          Form.submit(form, ({firstName, lastName, rating, matchCount}) =>
            playersDispatch(
              Db.Set(
                playerId,
                {Player.firstName, lastName, matchCount, rating, id: playerId, type_},
              ),
            )
          )
        }}>
        <p>
          <label htmlFor="firstName"> {React.string("First name")} </label>
          <input
            value=input.firstName
            onBlur={_ => Form.blurFirstName(form)}
            onChange={event => Form.updateFirstName(form, (event->ReactEvent.Form.target)["value"])}
            name="firstName"
            type_="text"
          />
        </p>
        {errorNotification(Form.firstNameResult(form))}
        <p>
          <label htmlFor="lastName"> {React.string("Last name")} </label>
          <input
            value=input.lastName
            onBlur={_ => Form.blurLastName(form)}
            onChange={event => Form.updateLastName(form, (event->ReactEvent.Form.target)["value"])}
            name="lastName"
            type_="text"
          />
        </p>
        {errorNotification(Form.lastNameResult(form))}
        <p>
          <label htmlFor="matchCount"> {React.string("Matches played")} </label>
          <input
            value=input.matchCount
            onBlur={_ => Form.blurMatchCount(form)}
            onChange={event =>
              Form.updateMatchCount(form, (event->ReactEvent.Form.target)["value"])}
            name="matchCount"
            type_="number"
          />
        </p>
        {errorNotification(Form.matchCountResult(form))}
        <p>
          <label htmlFor="rating"> {React.string("Rating")} </label>
          <input
            value=input.rating
            onBlur={_ => Form.blurRating(form)}
            onChange={event => Form.updateRating(form, (event->ReactEvent.Form.target)["value"])}
            name="rating"
            type_="number"
          />
        </p>
        {errorNotification(Form.ratingResult(form))}
        <p>
          <button disabled={Form.submitting(form) || !Form.valid(form)}>
            {Form.dirty(form) ? "Save"->React.string : "Saved"->React.string}
          </button>
        </p>
      </form>
      <h3> {React.string("Players to avoid")} </h3>
      <AvoidForm playerId players config configDispatch />
      <hr />
      <h3> {React.string("Statistics")} </h3>
      <PlayerStats playerId />
      <hr />
      <details>
        <summary> {"Additional information"->React.string} </summary>
        <dl>
          <dt> {React.string("K-factor")} </dt>
          <dd className="monospace">
            {React.int(
              switch Form.matchCountResult(form) {
              | Some(Ok(matchCount)) => Ratings.EloRank.getKFactor(~matchCount, ~rating)
              | Some(Error(_)) | None =>
                Ratings.EloRank.getKFactor(~matchCount=initialMatchCount, ~rating)
              },
            )}
          </dd>
        </dl>
        <p className="caption-20">
          {`K-factor is 40 for players who have played fewer than 30 matches, 20 for players with
            a rating below 2100, and 10 for players with a rating above 2100.`->React.string}
        </p>
      </details>
    </div>
  }
}

@react.component
let make = (~id=?, ~windowDispatch) => {
  let {items: players, dispatch: playersDispatch, _} = Db.useAllPlayers()
  let (sorted, sortDispatch) = Hooks.useSortedTable(
    ~table=Map.valuesToArray(players),
    ~column=sortFirstName,
    ~isDescending=false,
  )
  React.useEffect2(() => {
    sortDispatch(SetTable(Map.valuesToArray(players)))
    None
  }, (players, sortDispatch))
  let (config, configDispatch) = Db.useConfig()
  <Window.Body windowDispatch>
    {switch id {
    | None =>
      <PlayerList sorted sortDispatch players playersDispatch configDispatch windowDispatch />
    | Some(id) =>
      switch Map.get(players, id) {
      | None => <div> {React.string("Loading...")} </div>
      | Some(player) =>
        <Profile player players playersDispatch config configDispatch windowDispatch />
      }
    }}
  </Window.Body>
}
