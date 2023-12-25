# Shiny Application for Bibliography Analysis Documentation

- [Overview](#overview)
- [Application Structure](#application-structure)
  - [Data Loading](#data-loading)
    - [XML File (JabRef Bibliography)](#xml-file-jabref-bibliography)
    - [DataFrame (Terms in English and Spanish)](#dataframe-terms-in-english-and-spanish)
- [Presence/Absence Matrix Generation](#presenceabsence-matrix-generation)
- [Multiple Correspondence Analysis (MCA)](#multiple-correspondence-analysis-mca)
- [K-Means Clustering](#k-means-clustering)
- [Technical Considerations](#technical-considerations)
  - [R Dependencies](#r-dependencies)
- [Conclusions and Recommendations](#conclusions-and-recommendations)


## Overview
This Shiny application is designed to analyze bibliographies exported from [JabRef](https://www.jabref.org/) in XML format. It facilitates the comparison of key terms in English and Spanish and uses multivariate analysis and clustering techniques to identify patterns and groupings in the data.

## Application Structure

1. **Data Loading**
	 1. **XML File (JabRef Bibliography):**
    
	    - **Format:** XML
	    - **Content:** This file is expected to be a JabRef-formatted bibliography. JabRef bibliographies typically contain structured bibliographic data, including information like authors, titles, publication years, journal names, and other relevant citation details.
	    - **Use Case:** This input is ideal for users who wish to process bibliographic data, especially for academic or research purposes. The XML format ensures structured and consistent data handling.
	    - **Processing:** Uploaded XML files are processed to extract and convert bibliographic information into a structured DataFrame. This process involves parsing XML tags specific to JabRef formatting.
	2. **DataFrame (Terms in English and Spanish):**
	    
	    - **Format:** This data can be uploaded in various formats, such as CSV or Excel, but should be convertible to a DataFrame structure.
	    - **Content:** The DataFrame should contain terms or phrases in both English and Spanish. It can be structured with different columns, but the primary focus is on bilingual term data.
	    - **Use Case:** This input is useful for users dealing with bilingual data analysis, language studies, or any application that requires the processing of terms in both English and Spanish.
	    - **Processing:** The application reads the uploaded file, converting it into a DataFrame format if not already in one. It then processes the bilingual terms for the intended analytical or operational purposes.

	![](./supplemental_documentation /images/load_interface.png)

---

## Presence/Absence Matrix Generation

Upon successful upload and processing of input data, our application constructs a presence/absence matrix. This matrix serves as a cornerstone for bibliometric analysis by mapping the occurrence of predefined terms within a set of bibliography abstracts.

**Matrix Structure:**

- **Rows:** Each row corresponds to a unique bibliographic entry, identified by titles and authors' names.
- **Columns:** Each column beyond the bibliographic identifiers represents a term from the uploaded term list.
- **Cells:** The cells contain binary values: '1' indicates the presence of the term in the corresponding abstract, and '0' denotes its absence.

**Functionalities:**

- **Apply absDummy:** This function transforms the textual data from the abstracts into a binary matrix, considering the provided term list.
- **Download Data:** Users can export the generated matrix for further analysis or reporting.
- **Search:** A search bar allows users to filter the matrix dynamically based on keywords or terms.

**Analysis Capability:** The matrix supports various types of analyses, including term frequency assessment, co-occurrence examination, and trend analysis over the bibliographic corpus. It provides a quantitative foundation for understanding the scope and focus of the literature within the specified domain.

3. **Multivariate Analysis**
   - **Method**: Multiple Correspondence Analysis (MCA) using the Burt matrix.
   - **Goal**: To uncover patterns and relationships between terms and documents.

4. **Clustering**
   - **Method**: K-means clustering applied to the results of MCA.
   - **Objective**: To group documents into clusters based on term similarities.
   - **Visualization**: Potential use of graphics to display the clusters.
   
	![](./supplemental_documentation /images/absDummy.png)


## Multiple Correspondence Analysis (MCA)

After the presence/absence matrix is created using the `absDummy` function, our application offers the capability to conduct Multiple Correspondence Analysis (MCA) on this data. MCA is a statistical technique used to detect and represent underlying structures in categorical data.

**Analysis Workflow:**

1. **Running MCA:**
    
    - Users can initiate the MCA analysis by selecting the 'Run MCA Analysis' option. This triggers the computation of dimensions that capture the variance in the data.
2. **Interpreting MCA Results:**
    
    - The results table displays eigenvalues, percentage of variance, and cumulative percentage of variance for each dimension calculated by the MCA.
    - This quantifies how much of the data's variability is represented by each dimension, helping to identify the most significant patterns.
3. **Visualization:**
    
    - The 'Variable Plot' shows the relationships between terms based on their co-occurrence across the abstracts.
    - The plot is interactive, allowing users to visually explore the associations between terms in a two-dimensional space, usually along the two dimensions that capture the most variance.

**Features:**

- **Options to Refine Analysis:**
    
    - The application provides checkboxes to show or hide different plots, such as 'Variable Plot' or 'Observations Plot', allowing for customizable visual output.
    - A 'Show Presences Only'.This option refines the analysis by visualizing only the co-occurrences of terms within the abstracts. When enabled, it filters out the non-occurring events, allowing users to focus exclusively on the relationships and associations formed by the terms that do appear in the dataset. This feature is particularly useful for highlighting and investigating the patterns and connections between terms that are actively present in the literature.
- **Data Navigation:**
    
    - Users can adjust the number of entries shown in the results table and use a search function to locate specific terms or data points within the MCA output.

**Utility:** MCA is particularly valuable in exploratory data analysis, providing insights into the complex relationships between terms within a large corpus of text. It can be used for pattern recognition, hypothesis generation, and enhancing the understanding of thematic structures in bibliographic datasets.

![](./supplemental_documentation /images/MCA.png)


## K-Means Clustering

Following the MCA, users have the option to apply K-Means clustering to the data. This statistical method partitions the entries into clusters, with the aim of minimizing the variance within each cluster and maximizing the variance between clusters.

**Clustering Process:**

1. **Parameter Setting:**
    
    - **Set Seed:** Users can specify a seed for the random number generator to ensure reproducibility of the clustering results.
    - **Number of Centers:** Users define the desired number of clusters (centers) for the algorithm to generate.
2. **Cluster Analysis Execution:**
    
    - By selecting 'Run K-Means', the algorithm begins processing the data based on the provided parameters. It iteratively assigns each entry to the nearest cluster center and updates the centers until convergence is reached.

**Results and Visualization:**

- **K-Means Centers Table:** Displays the coordinates of the cluster centers across all dimensions resulting from the MCA.
- **Cluster Plot:** A visual representation of the clusters is shown, where each point represents an entry, color-coded by its assigned cluster. This aids in visualizing the distribution and relationship of entries within the multi-dimensional space.

**Features:**

- **Interactive Table:** The results table allows users to explore the detailed cluster assignments for each entry. It is searchable and supports pagination for ease of navigation.
- **Visualization Options:** Users can toggle the display of the cluster graph for a graphical overview of the clustering.

**Utility:** K-Means clustering is utilized to discover natural groupings in the data, identify patterns, and suggest categorizations that may not be immediately apparent. It is especially useful in uncovering thematic concentrations and variations within the bibliographic abstracts.

![](./supplemental_documentation /images/k-means.png)


## Technical Considerations
### R Dependencies

The application leverages several R packages for its operations, each serving a specific purpose in the data analysis workflow:

- **shiny**: For building the interactive web application.
- **DT**: For rendering interactive data tables.
- **FactoMineR**: For performing the Multiple Correspondence Analysis (MCA).
- **factoextra**: For extracting and visualizing the results of multivariate data analyses.
- **plotly**: For creating interactive plots.
- **cluster**: For executing clustering algorithms such as K-Means.
- **shinyWidgets**: For enhancing UI elements in the Shiny application.
- **Optimization and Scalability**: Considerations for handling large datasets.

## Conclusions and Recommendations
- **Potential Uses**: Ideal for researchers and academics to analyze trends in literature.
- **Future Improvements**: Possible extensions include more advanced text analysis, integration with other bibliographic databases, etc.

