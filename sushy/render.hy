(import 
    [time [time]]
    [logging [getLogger]]    
    [textile [textile]]
    [smartypants [smartyPants]]
    [markdown [Markdown]]
    [docutils.core [publish-parts]])
        
(setv log (getLogger))

(defn render-html [raw]
    raw)
    
(defn render-plaintext [raw]
    (% "<pre>\n%s</pre>" raw))
    
(defn render-restructured-text [raw]
    (get (apply publish-parts [raw] {"writer_name" "html"}) "html_body"))
    
(defn render-markdown [raw]
    (.convert 
        (apply Markdown [] 
            {"extensions" ["markdown.extensions.extra" 
                           "markdown.extensions.toc" 
                           "markdown.extensions.smarty" 
                           "markdown.extensions.codehilite" 
                           "markdown.extensions.meta" 
                           "markdown.extensions.sane_lists"]})
                raw))
                
(defn render-textile [raw]
    (smartyPants (apply textile [raw] {"head_offset" 0
                                       "html_type"   "html"})))

(def render-map 
   {"text/plain"          render-plaintext
    "text/rst"            render-restructured-text ; unofficial, but let's be lenient
    "text/x-rst"          render-restructured-text ; official
    "text/x-web-markdown" render-markdown
    "text/x-markdown"     render-markdown
    "text/markdown"       render-markdown
    "text/textile"        render-textile
    "text/x-textile"      render-textile
    "text/htm"            render-html})
    
    
(defn render-page [page]
    (apply (get render-map (get (:headers page) "content-type")) [(:body page)] {}))


(defn sanitize-title [title]
    (re.sub "[\W+]" "-" (.lower title)))
