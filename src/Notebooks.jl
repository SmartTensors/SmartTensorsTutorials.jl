import Mads

notebook(a...; k...) = Mads.notebook(a...; dir=JuliaWorkshop.dir, k...)
notebooks(a...; k...) = Mads.notebooks(a...; dir=JuliaWorkshop.dir, k...)
notebookscript(a...; k...) = Mads.notebookscript(a...; dir=JuliaWorkshop.dir, k...)
process_notebook(a...; k...) = Mads.process_notebook(a...; dir=JuliaWorkshop.dir, k...)