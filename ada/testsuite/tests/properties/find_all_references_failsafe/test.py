from __future__ import absolute_import, division, print_function

import os
import sys

import libadalang as lal


ctx = lal.AnalysisContext(unit_provider=lal.UnitProvider.auto(sys.argv[1:]))
all_units = [
    ctx.get_from_file(f) for f in sys.argv[1:]
]


for unit in all_units:
    if len(unit.diagnostics) > 0:
        print(unit.diagnostics)


def find_name(unit_name, name_text, line_no=None):
    unit = ctx.get_from_file(unit_name)
    return unit.root.find(
        lambda x: (
            x.is_a(lal.DefiningName) and x.text == name_text and
            line_no is None or x.sloc_range.start.line == line_no
        )
    )


for unit, name in [('a.ads', 'X'), ('b.adb', 'Y')]:
    print('All references to {} from {}:'.format(name, unit))
    name_node = find_name(unit, name)
    for ref in name_node.p_find_all_references(all_units,
                                               imprecise_fallback=True):
        while ref.parent is not None and not ref.p_xref_entry_point:
            ref = ref.parent

        print('    {} ({}, {})'.format(
            ref.text.splitlines()[0],
            os.path.basename(ref.unit.filename),
            ref.sloc_range)
        )

print('Done')
