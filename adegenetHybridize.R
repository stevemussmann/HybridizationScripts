#!/usr/local/bin/Rscript

library(adegenet)
library(optparse)
library(radiator)

option_list = list(
	make_option(
		c("-p", "--par1gen"),
		type="character",
		default=NULL,
		help="Genepop file for first parental species.",
		metavar="character"
	),
	make_option(
		c("-P", "--par2gen"),
		type="character",
		default=NULL,
		help="Genepop file for second parental species.",
		metavar="character"
	),
	make_option(
		c("-n", "--ninds"),
		type="integer",
		default=50,
		help="Number of individuals to simulate in each simulated group.",
		metavar="integer"
	),
	make_option(
		c("-o", "--out"),
		type="character",
		default="output",
		help="Output file prefix.",
		metavar="character"
	)
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

#read filtered genepop input
if(!is.null(opt$par1gen)){
	parental1 <- read.genepop(opt$par1gen, ncode=3L, quiet=FALSE)
} else {
	stop("First parental genepop file (-p, --par1gen) must be specified. See script usage(--help).")
}

if(!is.null(opt$par2gen)){
	parental2 <- read.genepop(opt$par2gen, ncode=3L, quiet=FALSE)
} else {
	stop("Second parental genepop file (-P, --par2gen) must be specified. See script usage(--help).")
}

#parental1$all.names

##simulate hybridized populations
#F1
f1sim<-hybridize(parental1,parental2,opt$ninds,pop="F1Sim",hyb.label="f1_")

#F2
f2sim<-hybridize(f1sim, f1sim, opt$ninds, pop="F2Sim", hyb.label="f2_")
p1bx<-hybridize(parental1, f1sim, opt$ninds, pop="P1Bx", hyb.label="p1bx_")
p2bx<-hybridize(parental2, f1sim, opt$ninds, pop="P2Bx", hyb.label="p2bx_")

#F3
f1Xf2<-hybridize(f1sim, f2sim, opt$ninds, pop="F1_x_F2", hyb.label="f1xf2_")
f3sim<-hybridize(f2sim, f2sim, opt$ninds, pop="F3Sim", hyb.label="f3_")
p1Xp2bx<-hybridize(parental1, p2bx, opt$ninds, pop="P1_x_P2Bx", hyb.label="p1Xp2bx_")
p2Xp1bx<-hybridize(parental2, p1bx, opt$ninds, pop="P2_x_P1Bx", hyb.label="p2Xp1bx_")
p1bx2<-hybridize(parental1, p1bx, opt$ninds, pop="P1Bx2", hyb.label="p1bx2_")
p2bx2<-hybridize(parental2, p2bx, opt$ninds, pop="P2Bx2", hyb.label="p2bx2_")
p1bxXp1bx<-hybridize(p1bx, p1bx, opt$ninds, pop="P1Bx_x_P1Bx", hyb.label="p1bxXp1bx_")
p2bxXp2bx<-hybridize(p2bx, p2bx, opt$ninds, pop="P2Bx_x_P2Bx", hyb.label="p2bxXp2bx_")
p1bxXf1<-hybridize(p1bx, f1sim, opt$ninds, pop="P1Bx_x_F1", hyb.label="p1bxXf1_")
p2bxXf1<-hybridize(p2bx, f1sim, opt$ninds, pop="P2Bx_x_F1", hyb.label="p2bxXf1_")
p1bxXf2<-hybridize(p1bx, f2sim, opt$ninds, pop="P1Bx_x_F2", hyb.label="p1bxXf2_")
p2bxXf2<-hybridize(p2bx, f2sim, opt$ninds, pop="P2Bx_x_F2", hyb.label="p2bxXf2_")
p1bxXp2bx<-hybridize(p1bx, p2bx, opt$ninds, pop="P1Bx_x_P2Bx", hyb.label="p1bxXp2bx_")

# pull all data together
simData <- repool(
	parental1, parental2, #parental species
	f1sim, #f1 pops
	f2sim, p1bx, p2bx, #f2 pops
	f1Xf2, f3sim, p1Xp2bx, p2Xp1bx, p1bx2, p2bx2, p1bxXp1bx, p2bxXp2bx, p1bxXf1, p2bxXf1, p1bxXf2, p2bxXf2, p1bxXp2bx #f3 pops
)

genomic_converter(simData, output="genepop", filename=opt$out, verbose=TRUE)

simData

quit()
