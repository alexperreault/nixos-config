// Subsequence-fuzzy match + score, applied to name/genericName/keywords, with
// a frecency tiebreaker sourced from usage.json (see Launcher.qml). Good
// enough for a handful of dozens of installed apps.

function frecency(usage, id, now) {
    var u = usage && usage[id]
    if (!u || !u.count) return 0
    var ageHours = Math.max(0, (now - u.last) / 3600000)
    return u.count / (ageHours + 2)
}

function score(entry, query) {
    if (!query) return 0
    var q = query.toLowerCase()
    var name = String(entry.name || "").toLowerCase()

    if (name === q) return 100
    if (name.indexOf(q) === 0) return 80
    if (name.indexOf(q) >= 0) return 60

    var generic = String(entry.genericName || "").toLowerCase()
    if (generic.indexOf(q) >= 0) return 40

    // subsequence match on name, e.g. "ffx" matches "firefox"
    var qi = 0
    for (var i = 0; i < name.length && qi < q.length; i++) {
        if (name[i] === q[qi]) qi++
    }
    if (qi === q.length) return 20

    return -1
}

function filter(applications, query, usage) {
    var now = Date.now()
    var visible = []
    for (var i = 0; i < applications.length; i++) {
        var entry = applications[i]
        if (entry.noDisplay) continue
        visible.push(entry)
    }

    if (!query) {
        visible.sort(function(a, b) {
            var fa = frecency(usage, a.id, now)
            var fb = frecency(usage, b.id, now)
            if (fb !== fa) return fb - fa
            return String(a.name).localeCompare(String(b.name))
        })
        return visible
    }

    var scored = []
    for (var j = 0; j < visible.length; j++) {
        var s = score(visible[j], query)
        if (s >= 0) scored.push({ entry: visible[j], score: s, frecency: frecency(usage, visible[j].id, now) })
    }
    scored.sort(function(a, b) {
        if (b.score !== a.score) return b.score - a.score
        if (b.frecency !== a.frecency) return b.frecency - a.frecency
        return String(a.entry.name).localeCompare(String(b.entry.name))
    })
    return scored.map(function(x) { return x.entry })
}
