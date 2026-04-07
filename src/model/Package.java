package model;

public class Package {
    private int packageId;
    private String dbPackageId; // e.g. 'P001' from database
    private String packageName;
    private String category;
    private String price;
    private int sessions;
    private int durationPerSession;
    private String description;
    private boolean popular;
    private String gradient;
    private String ageRange;

    public Package() {
    }

    public Package(int packageId, String packageName, String category, String price, int sessions, 
                   int durationPerSession, String description, boolean popular, String gradient) {
        this.packageId = packageId;
        this.packageName = packageName;
        this.category = category;
        this.price = price;
        this.sessions = sessions;
        this.durationPerSession = durationPerSession;
        this.description = description;
        this.popular = popular;
        this.gradient = gradient;
        this.ageRange = null;
    }

    public int getPackageId() {
        return packageId;
    }

    public void setPackageId(int packageId) {
        this.packageId = packageId;
    }

    public String getDbPackageId() {
        return dbPackageId;
    }

    public void setDbPackageId(String dbPackageId) {
        this.dbPackageId = dbPackageId;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getPrice() {
        return price;
    }

    public void setPrice(String price) {
        this.price = price;
    }

    public int getSessions() {
        return sessions;
    }

    public void setSessions(int sessions) {
        this.sessions = sessions;
    }

    public int getDurationPerSession() {
        return durationPerSession;
    }

    public void setDurationPerSession(int durationPerSession) {
        this.durationPerSession = durationPerSession;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isPopular() {
        return popular;
    }

    public void setPopular(boolean popular) {
        this.popular = popular;
    }

    public String getGradient() {
        return gradient;
    }

    public void setGradient(String gradient) {
        this.gradient = gradient;
    }

    public String getAgeRange() {
        return ageRange;
    }

    public void setAgeRange(String ageRange) {
        this.ageRange = ageRange;
    }
}
