# APADEMIDE CORE

## Background
`APADEMIDE CORE` is a set of scripts that provide many useful features for Denizen Scripters.

For you to appreciate this document and `APADEMIDE CORE` globally, you must already be familiar with Denizen and scripting.
If there's already terms you didn't understand at this point, it means that's most likely not the case. [Discover what Denizen is here](https://guide.denizenscript.com/guides/background/what-is-denizen), or [join the Discord server](https://discord.gg/Q6pZGSR)!

## Glossary
In order to ensure this documention is clear for everyone to read, let's start with some definitions.   
If you're reading this for the first time, please toggle that menu and read the few concepts explained!

<details><summary><b>Glossary</b></summary>
<p>

### Naming things

Denizen already has its own [objects types](https://meta.denizenscript.com/Docs/ObjectTypes).
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

---

</details>

### Syntax

The same way as Denizen has ObjectsTypes, Denizen has [its own syntax](https://meta.denizenscript.com/Docs/Languages/#command%20syntax).
And again, where applicable, `APADEMIDE CORE` uses it.

<details><summary><code>Distinguishing Denizen and APADEMIDE CORE</code></summary>
<p>

Nevertheless, as you already discovered, since a few concepts vary slightly from *raw* Denizen, we need to clearly know what we're talking about.

<details><summary><code>How to distinguish…</code></summary>

---

You may already have noticed it, when we mention `APADEMIDE CORE`'s `PROCEDURES`, they're written in uppercase and monospace font, while *raw* Denizen procedures aren't specifically highlighted. That's pretty much it!

When something is directly powered by `APADEMIDE CORE`, it's in `UPPERCASE MONOSPACE`, otherwise it uses basic synthax. This way, if we talk about a ListTag it's a Denizen object, but if we talk about an `ENUM`, it's a "`APADEMIDE CORE` object", which is internally a MapTag containing a list of options and data about how to deal with it.

Very simple, right?

---

</details>

### `APADEMIDE CORE`

As the name implies, this is the heart of this system.

<details><summary><code>More details…</code></summary>

Made up of multiple various scripts, `APADEMIDE CORE` provides many utilities and shortcuts that achieve tasks of all kinds.
Since Denizen is already very complete by itself, the main aim is to provide tools that fastens the scripting process.
To allow scripters to use the `CORE` to its full potential, it has been thought for extesivity since the beginning.

In this documentation, `APADEMIDE CORE` will be mentionned by a few aliases. If we talk about the `CORE`, the `system` or, obviously, `APADEMIDE CORE`, we're talking about that main block.

</details>
</p>
</details>


