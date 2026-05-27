global class PenetrationTestWrapper {
  public String name;
  public String external_scan_Id;
  public String scan_tool;
  public String scan_type;
  public Datetime scan_start_date;
  public Datetime scan_end_date;
  public List<Vulnerability> vulnerabilities_found;

  global class Vulnerability {
    public String name;
    public String cwe_code;
    public String owasp_category;
    public String severity;
    public String bussines_impact;
  }
}
