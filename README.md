# APADEMIDE CORE

## Background
`APADEMIDE CORE` is a set of scripts that provide many useful features for Denizen Scripters.

For you to appreciate this document and `APADEMIDE CORE` globally, you must already be familiar with Denizen and scripting.
If there's already terms you didn't understand at this point, it means that's most likely not the case.   
[Discover what Denizen is here](https://guide.denizenscript.com/guides/background/what-is-denizen), or [join the Discord server](https://discord.gg/Q6pZGSR)!

## Glossary
In order to ensure this documention is clear for everyone to read, let's start with some definitions.   
If you're reading this for the first time, please toggle that menu and read the few concepts explained!

<details><summary><b>Glossary</b></summary>
<p>
  
---

### Naming things

Denizen already has its own [ObjectTypes](https://meta.denizenscript.com/Docs/ObjectTypes).
Where applicable, `APADEMIDE CORE` uses it. However, some may differ a little.

<details><summary><code>Differences…</code></summary>

---

Obviously, as `APADEMIDE CORE` is made with and for Denizen scripts, it uses Denizen objects.
However, in order to facilitate the comprehension of what data is required where and to allow some more precise inputs, a few "sub-types" are used.

### Concrete exemple

Denizen uses [maps](https://meta.denizenscript.com/Docs/ObjectTypes/map#maptag). They are everywhere! [Flag structures](https://meta.denizenscript.com/Docs/Languages/flag#flag%20system) are maps, [data scripts](https://meta.denizenscript.com/Docs/Languages/data%20s#data%20script%20containers) are maps, many [mechanisms](https://meta.denizenscript.com/Docs/Languages/data%20script#data%20script%20containers) uses maps, you name it!

To navigate into those maps, query or set data, etc. we use "paths". A path in Denizen is an [ElementTag](https://meta.denizenscript.com/Docs/ObjectTypes/element#elementtag) which contains dots marking a "deeper level in the map". In `APADEMIDE CORE`, `PATH` is one of those sub-types of objects. Some `PROCEDURES` or commands requires a `PATH` input, other `PROCEDURES` allow to manage those `PATH`s, move between the levels, etc.

No worry, tho! It's still an ElementTag at the end of the day! No *real* custom object types mess. 

### Another exemple

We mentionned `PROCEDURES` above. You'll see them in details soon, but know that they're basically Denizen procedures on steroids.

Some `PROCEDURES` require some input data. And those inputs can be of various types, one of them being basically enums. You have a few options available to modify the determination and need to choose one. For that, an `ENUM` sub-type exists.

Again, it's obviously not reinventing the wheel. It mainly consists of `<[LIST_OF_OPTIONS].contains[<[INPUT]>]>`. However, instead of constantly having to repeat the same list of tags and apply the same logic again and again, the `PROCEDURE` uses a simple configuration for the `ENUM` and all the fallbacks, defaults values and NULL inputs are handled accordingly.

</details>

---
  
### Syntax

The same way as Denizen has ObjectTypes, Denizen has [its own syntax](https://meta.denizenscript.com/Docs/Languages/#command%20syntax).
And again, where applicable, `APADEMIDE CORE` uses it.

<details><summary><code>Distinguishing Denizen and APADEMIDE CORE</code></summary>

---
  
As you already discovered, since a few concepts vary slightly from *raw* Denizen, we need to clearly know what we're talking about.

### How to distinguish…

You may already have noticed it, when we mention `APADEMIDE CORE`'s `PROCEDURES`, they're written in uppercase and monospace font, while *raw* Denizen procedures aren't specifically highlighted. That's pretty much it!

When something is directly powered by `APADEMIDE CORE`, it's in `UPPERCASE MONOSPACE`, otherwise it uses no syntax. This way, if we talk about a ListTag it's a Denizen object, but if we talk about an `ENUM`, it's an "`APADEMIDE CORE` object", which is internally a MapTag containing a ListTag of options and data about how to deal with it.

Very simple, right?

</details>
  
---

### `APADEMIDE CORE`

As the name implies, this is the heart of this system.

<details><summary><code>More details…</code></summary>
  
---

Made up of multiple various scripts, `APADEMIDE CORE` provides many utilities and shortcuts that achieve tasks of all kinds.
Since Denizen is already very complete by itself, the main aim is to provide tools that fastens the scripting process.
To allow scripters to use the `CORE` to its full potential, it has been thought for extensivity since the beginning.

In this documentation, `APADEMIDE CORE` will be mentionned by a few aliases. If we talk about the `CORE`, the system or, obviously, `APADEMIDE CORE`, we're talking about that main block.

</details>

---

### `PROCEDURES`

Denizen procedures, but they tried the strange sugar mommy loves.

<details><summary><code>What are those?</code></summary>
  
---

Using procedures can sometimes get annoying. As you progress and add features to your server, you can quickly raise their number and end up dealing with dozens of them.

You have to remember all their script names, you probably had to add prefixes to prevent conflicts, maybe you added information to know if it is used for Locations, EntityTags, etc. So at the end, a basic procedure that gets the entities near a location get called `serverPrefix_location_get_near_entities`.
  
Not only you'll forget the script name by next week (and that'd be longer than me), you'd have to actually *create* the whole procedure too.
You may be confused because, yeah, obviously I'd have to create the procedure…? But it's actually really annoying!

<details><summary><code>Let's see why!</code></summary>
<br/>

```denizenscript
serverPrefix_location_get_near_entities:
    type: procedure
    debug: false
    # You probably want to get a radius in addition to the location
    definitions: LOCATION|RADIUS
    script:
    # First, you have to check if the location is actually provided
    - if !<[LOCATION].exists>:
      - determine ERROR
    # You then want to validate the input is a location and handle wrong inputs
    - define LOCATION <[LOCATION].as[location].if_null[NULL]>
    - if <[LOCATION]> == NULL:
      - determine ERROR
    # Then you want to check wether the input exists
    # If unspecified, a fallback value should work
    - if !<[RADIUS].exists>:
      - define RADIUS 10
    # But if the input exists, you must validate it is a number
    # Otherwise, an input that isn't a number is probably caused by an error
    # in the script so you may want to error instead of using the fallback
    - else if !<[RADIUS].is_decimal>:
      - determine ERROR
    # At this point you're safe with both definitions
    # If the radius isn't set, it is defined with a fallback value
    # If the radius is set wrongly, the proc returned an error
    # so now you've got a valid decimal
    # And the location definition is a valid location too
```

Amazing, right? 9 lines of script, 14 lines if you count the keys at the top.  
And you have… nothing yet! At this point and only at this point you may start to work on the actual logic. So let's do it!

```denizenscript
    - determine <[LOCATION].find_entities.within[<[RADIUS]>]>  
```

And that's it! All the script before to only validate two tags that are used in a single line.
Now imagine if we wanted to add a `<[MATCHER]>` input to get only specific entities.

### `APADEMIDE CORE`'s equivalent

[I'm obviously not saying validating inputs is bullshit](https://guide.denizenscript.com/guides/troubleshooting/common-mistakes.html#don-t-trust-players). The problem is that we're always duplicating the same snippets of code.
We've probably all already tried injecting validator snippets, but we end up having the same problem with long, impossible to remember names. Plus the fact there's often one tweak required that makes the task impossible to inject.

So here's the `APADEMIDE CORE`'s equivalent:

```denizenscript
  # This key is a "namespace".
  # The details of how it works is detailed further in the document, but the most important to remember right now
  # is that you can organize `PROCEDURES` like a map, and access them as with maps.
  location:
    get_near_entities:
      # This is where the input is configured
      input_data:
        # The definition that'll be available with "LOCATION" is of type: location
        # Nothing else is defined, so by default the input is mandatory and must be of the given type
        LOCATION:
          type: location
        # Here, we want a decimal input
        # null: true says that it's okay to let the input empty; not specifiying it won't error
        # fallback: 10 is a, as you could've guessed, a fallback value that's applied if nothing have been inputted
        # null: true without a fallback results in simply not having the definition available
        RADIUS:
          type: decimal
          null: true
          fallback: 10
      script:
        # Here, the only difference with the previous exemple is that the
        # definitions are accessed through the <[DATA]> definitions map
        - determine <[DATA.LOCATION].find_entities.within[<[DATA.RADIUS]>]>
```
 
From 14 lines we get to 11. The number is not impressive, right? But we saved a lot of time because instead of thinking about all possible edge cases for the 20th time, we simply had to write a real quick config data key.

Two other improvements of that are:
1. Input types (here `location` and `decimal`) allow some additionnal internal processing. For exemple, the location input could actually be an EntityTag and the conversion to its location would be automatic. For the decimal, assuming it'd be used with an user input, it'd automatically convert comma-decimals to dot-decimals, making 2,5 work as great as 2.5, and same for .5 or 0.5.
2. The fallback can be different! In a standard procedure, if we injected a task script for validation, we could only have a single fallback for all decimals. Here, each case has its fallback that makes sense!

#### How to use it?
  
Now that we have that configured `PROCEDURE`, here's the syntax to use it:
  
```denizenscript
<map[LOCATION=<player>;RADIUS=5].proc[APADEMIDE].context[LOCATION.GET_NEAR_ENTITIES]>
```
As you can see, it takes two inputs. One is a map with all inputs names and their values, the other is the `PATH` to the procedure.
The order of the inputs doesn't matter and the map is automatically parsed internally, meaning all the following syntaxes are valid:
  
```denizenscript
# Option 1
- define ENTITIES <element[LOCATION.GET_NEAR_ENTITIES].proc[APADEMIDE].context[LOCATION=<player>;RADIUS=5]>

# Option 2
- definemap DATA:
    LOCATION: <player.location>
    RADIUS: ,4
- define ENTITIES <[DATA].proc[APADEMIDE].context[LOCATION.GET_NEAR_ENTITIES]>

# Option 3
- define ENTITIES <proc[APADEMIDE].context[LOCATION.GET_NEAR_ENTITIES|LOCATION=<location[SPAWN]>;RADIUS=5]>
```

`PROCEDURES` that do not require inputs can be used simply with:
```denizenscript
- define CONFIG_MAP <proc[APADEMIDE].context[CONFIG]>
```
Sweet, right?
  
That's it for the main differences between procedures and `PROCEDURES`!
  
</details>  

</details>


</p>
</details>


