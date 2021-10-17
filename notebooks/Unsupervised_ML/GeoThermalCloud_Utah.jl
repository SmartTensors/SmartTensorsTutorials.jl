import GeoThermalCloud
import NMFk
import Mads
import DelimitedFiles
import JLD
import Gadfly
import Cairo
import Fontconfig
import Kriging
import GMT
import Images

Xdat, headers = DelimitedFiles.readdlm("utah/data/utah_geothermal_data.csv", ',', header=true);

xcoord = Array{Float32}(Xdat[:, 2])
ycoord = Array{Float32}(Xdat[:, 1]);

GMT.grdimage("utah/maps/utah.nc", proj=:Mercator, shade=(azimuth=100, norm="e0.8"),
	color=GMT.makecpt(color=:grayC, transparency=10, range=(0,5000,500), continuous=true),
	figsize=8, conf=(MAP_FRAME_TYPE="plain", MAP_GRID_PEN_PRIMARY="thinnest,gray,.",
	MAP_GRID_CROSS_SIZE_SECONDARY=0.1, MAP_FRAME_PEN=0.5, MAP_TICK_PEN_PRIMARY=0.1,
	MAP_TICK_LENGTH_PRIMARY=0.01), frame=(axis="lrtb"))
GMT.plot!(xcoord, ycoord, fill=:cyan, marker=:c, markersize=0.1, coast=(proj=:Mercator, 
    DCW=(country="US.UT", pen=(0.5,:black))),
    fmt=:png, savefig="utah/maps/locations");
Images.load("utah/maps/locations.png")

attributes = ["Temperature", "Quartz", "Chalcedony", "pH", "TDS", "Al", "B", "Ba", "Be", "Br", "Ca", "Cl", "HCO3", "K", "Li", "Mg", "Na", "δO18"]
attributes_long = ["Temperature (C)", "GTM quartz (C)", "GTM chalcedony (C)", "pH ()", "TDS (ppm)", "Al (ppm)", "B (ppm)", "Ba (ppm)", "Be (ppm)", "Br (ppm)", "Ca (ppm)", "Cl (ppm)", "HCO3 (ppm)", "K (ppm)", "Li (ppm)", "Mg (ppm)", "Na (ppm)", "δO18 (‰)"];

Xdat[Xdat .== ""] .= NaN;

X = convert.(Float32, Xdat[:,3:end]);

X[:,18] .+= 20;

nattributes = length(attributes_long)
npoints = size(Xdat, 1)

NMFk.datanalytics(X, attributes_long; dims=2);

coord = permutedims([xcoord ycoord])

xgrid, ygrid = NMFk.griddata(xcoord, ycoord; stepvalue=0.1)

for i = 1:nattributes
	inversedistancefield = Array{Float64}(undef, length(xgrid), length(ygrid))
	v = X[:,i]
	iz = .!isnan.(v)
	icoord = coord[:,iz]
	v = v[iz]
	for (i, x) in enumerate(xgrid), (j, y) in enumerate(ygrid)
		inversedistancefield[i, j] = Kriging.inversedistance(permutedims([x y]), icoord, v, 2; cutoff=1000)[1]
	end
	imax = NMFk.maximumnan(inversedistancefield)
	imin = NMFk.minimumnan(inversedistancefield)
	NMFk.plotmatrix(rotl90(inversedistancefield); quiet=false, filename="utah/maps/Attribute_$(attributes[i])_map_inversedistance.png", title="$(attributes[i])", maxvalue=imin + (imax - imin)/ 2)
end

logv = [true, false, false, false,  true, true, true, true, true, true, true, true, true, true, true, true, true, true]
[attributes logv]

NMFk.datanalytics(X, attributes; dims=2, logv=logv);

Xnl, xlmin, xlmax, zflag = NMFk.normalizematrix_col(X; logv=logv);

nkrange = 2:10

resultdir = "utah/results";

nruns = 100;

#W, H, fitquality, robustness, aic = NMFk.execute(Xnl, nkrange, nruns; cutoff=0.3, resultdir=resultdir, casefilename="nmfk-nl", load=true)
W, H, fitquality, robustness, aic = NMFk.load(nkrange, nruns; cutoff=0.3, resultdir=resultdir, casefilename="nmfk-nl");

NMFk.getks(nkrange, robustness[nkrange], 0.3)

NMFk.getk(nkrange, robustness[nkrange], 0.3)

resultdirpost = "utah/results-postprocessing-nl-$(nruns)"
figuredirpost = "utah/figures-postprocessing-nl-$(nruns)"
NMFk.plot_feature_selecton(nkrange, fitquality, robustness; figuredir=figuredirpost)

Sorder, Wclusters, Hclusters = NMFk.clusterresults(NMFk.getk(nkrange, robustness[nkrange], 0.3), W, H, string.(collect(1:npoints)), attributes; lon=xcoord, lat=ycoord, resultdir=resultdirpost, figuredir=figuredirpost, ordersignal=:Wcount, Hcasefilename="attributes", Wcasefilename="locations", biplotcolor=:WH, sortmag=false, biplotlabel=:H, point_size_nolabel=2Gadfly.pt, point_size_label=4Gadfly.pt)

Mads.display("utah/results-postprocessing-nl-100/attributes-3-groups.txt")

locations, lhs = DelimitedFiles.readdlm("utah/results-postprocessing-nl-100/locations-3.csv", ',', header=true)
clusters = sort(unique(locations[:,end]))
for i=1:size(clusters,1)
	locations[locations .== clusters[i]] .= Integer(i)
end
locations = convert.(Float32, locations)

GMT.grdimage("utah/maps/utah.nc", shade=(azimuth=100, norm="e0.8"), proj=:Mercator,
    color=GMT.makecpt(color=:grayC, transparency=10, range=(0,5000,500), continuous=true),
    figsize=8, conf=(MAP_FRAME_TYPE="plain", MAP_GRID_PEN_PRIMARY="thinnest,gray,.", MAP_GRID_CROSS_SIZE_SECONDARY=0.1, MAP_FRAME_PEN=0.5, MAP_TICK_PEN_PRIMARY=0.1, MAP_TICK_LENGTH_PRIMARY=0.01, FORMAT_GEO_MAP="ddd", FONT_ANNOT_PRIMARY=0.1, FONT_ANNOT_SECONDARY=0.1), frame=(axis="lrtb"))
GMT.legend!(box=(pen=false, fill=:white),
            pos=(inside=true, anchor=:T, width=1.30, justify=:CM, offset=(-0.7, -0.6)),
            GMT.text_record([
                "S 0.10i c 0.10i red  0.25p 0.2i A"
                "S 0.10i c 0.10i gold 0.25p 0.2i B"
                "S 0.10i c 0.10i blue 0.25p 0.2i C"]),
            par=(:FONT_ANNOT_PRIMARY, "8p,Arial"))
GMT.scatter!(locations[:,2], locations[:,3], marker=:c, markersize=:0.15,
    color=(:red, :gold, :blue), zcolor=locations[:,end], alpha=10,
    coast=(proj=:Mercator, 
    DCW=(country="US.UT", pen=(0.5,:black))),
    fmt=:png, savefig="utah/maps/signatures-3")
Images.load("utah/maps/signatures-3.png")
