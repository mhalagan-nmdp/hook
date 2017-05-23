import org.bdgenomics.adam.rdd.ADAMContext._
import org.bdgenomics.adam.models.ReferenceRegion

val bamfile = args(0)
val outbam = args(1)
val mhc = new ReferenceRegion("6", 28510120L, 33480577L)
val alignments = sc.loadIndexedBam(bamfile, mhc)
val alignmentsSorted = alignments.sortLexiocgraphically()
alignmentsSorted.saveAsSam(outbam, asSingleFile = true)


