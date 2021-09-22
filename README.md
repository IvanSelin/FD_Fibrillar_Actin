# FD_Fibrillar_Actin
Matlab function for measuring Minkovsky's fractal dimension of cellular fibrillar actin on a set of images.


USAGE:
====

fractal_wrapp_rotate_average(file_mask)


input:
----

   file_mask: A file mask describing set of files. Could point for a signle file, set of files, files in subdirectory, etc.
   
output:
----

   An excel file with filename "fractals_MM_DD_HH_mm_SS.xls" will be produced within the same directory. It will have 2 columns: filename and dimension. A row with filename and fractal dimension of given image will be inserted for every image specified by the file_mask


EXAMPLE 1: Process a single file.
----

    fractal_wrapp_rotate_average('example.tiff')

EXAMPLE 2: Process all .tiff files in current folder.
----

    fractal_wrapp_rotate_average('*.tiff')  

EXAMPLE 3: Process all .tiff files in subdirectory foo.
----

    fractal_wrapp_rotate_average('foo/*.tiff')


Written by Ivan Selin and Alla Revittser, 2021