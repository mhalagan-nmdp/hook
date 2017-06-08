import org.bdgenomics.adam.rdd.ADAMContext._
import org.bdgenomics.adam.models.ReferenceRegion


val bamfile = sys.env.get("BAMFILE").getOrElse("")
val outbam = sys.env.get("BAMOUT").getOrElse("")
val mhc = new ReferenceRegion("chr6", 28510120L, 33480577L)
val alignments = sc.loadIndexedBam(bamfile, mhc)
val filteredAlignments = alignments.transform(rdd => {        rdd.filter(_.getReadMapped)      })
val alignmentsSorted = filteredAlignments.sortLexicographically()
alignmentsSorted.saveAsSam(outbam, asSingleFile = true)


