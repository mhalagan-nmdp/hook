import org.bdgenomics.adam.rdd.ADAMContext._
import org.bdgenomics.adam.models.ReferenceRegion

val bamfile = args(0)
val outbam = args(1)
val mhc = new ReferenceRegion("chr6", 28510120L, 33480577L)
val alignments = sc.loadIndexedBam(bamfile, mhc)
val filteredAlignments = alignments.transform(rdd => {        rdd.filter(_.getReadMapped)      })
val alignmentsSorted = filteredAlignments.sortLexicographically()
alignmentsSorted.saveAsSam(outbam, asSingleFile = true)


